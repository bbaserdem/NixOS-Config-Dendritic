# Den policy on matching syncthing media folders to entities
{
  flib,
  lib,
  den,
  ...
}: let
  # Unify ignore patterns
  mkIgnoreText = host: folder: ''
    // Global ignore patterns for folder [${folder.name}]
    ${folder.ignore}

    // Host [${host.name}] specific ignore patterns
    ${folder.endpoints.${host.name}.ignore}
  '';
  mkIgnorePatterns = host: folder: {
    ignorePatterns = lib.splitString "\n" (mkIgnoreText host folder);
  };

  # Generate unified folder settings
  folderSettings = host: folder: path: let
    endpoint = folder.endpoints.${host.name};
  in
    (
      lib.recursiveUpdate
      folder.settings
      endpoint.settings
    )
    // {
      enable = true;
      inherit path;
      inherit (folder) id label;
      # ignorePatterns = ignorePatterns folder endpoint;
    };
  folderSettingsNixos = host: folder: path:
    (folderSettings host folder path) // (mkIgnorePatterns host folder);

  # Path rule to match modules/users/mediaDir.nix
  userPathRule = userName: {
    d = {
      user = userName;
      group = "users";
      mode = "0750";
    };
    "a+".argument =
      "g:users:rwX,m::rwX,"
      + "d:g:users:rwx,d:m::rwx";
  };
in {
  den = {
    # Auto-load folder dispatcher to every scope with syncthingFolder
    schema.syncthingFolder.includes = [
      den.aspects.syncthing.realizeMediaFolders
    ];

    aspects.syncthing = {
      provides = {
        # Module for realizing the syncthing configuration
        realizeMediaFolders = {
          host,
          syncthingFolder,
          ...
        } @ ctx: let
          # Joint home manager config generation
          hmConfig = parent: let
            mediaDir = parent.mediaDirs.${syncthingFolder.source.mediaDir}
              or (throw "Missing media directory ...");
          in (
            {...}: {
              services.syncthing.settings.folders.${syncthingFolder.name} =
                folderSettings host syncthingFolder "~/${mediaDir.location}";

              home.file."${mediaDir.location}/.stignore".text =
                mkIgnoreText host syncthingFolder;
            }
          );
        in
          # Standalone HM user
          if ctx ? home
          then {
            homeManager = hmConfig (
              if ctx ? user
              then ctx.user
              else ctx.home
            );
          }
          # Host with managed user
          else if ctx ? user
          then let
            user = ctx.user;
          in {
            # NixOS with the managed user
            nixos = {config, ...}: let
              mediaDir =
                user.mediaDirs.${
                  syncthingFolder.source.mediaDir
                } or (
                  throw ''
                    ${syncthingFolder.name} references missing media dir;
                    ${user.userName}.${syncthingFolder.source.mediaDir}
                  ''
                );
              userHome = config.users.users.${user.userName}.home;
              path = "${userHome}/${mediaDir.location}";
            in {
              services.syncthing.settings.folders.${syncthingFolder.name} =
                folderSettingsNixos host syncthingFolder path;

              # Give syncthing traversal through private home
              systemd.tmpfiles.settings = {
                "34-syncthing-${user.userName}-home"."${userHome}" = {
                  "a+".argument = "u:${config.services.syncthing.user}:--x";
                };
                "33-media-${user.userName}-parents" =
                  (flib.walkToDir userHome path)
                  |> lib.genAttrs (_: userPathRule user.userName);
              };
            };

            # Darwin with managed user
            homeManager =
              if ((host.class or null) == "darwin")
              then (hmConfig user)
              else {};
          }
          # Host shared with, but no user
          else {
            nixos = {config, ...}: let
              cfg = config.services.syncthing;
              userRoot = "${cfg.dataDir}/${syncthingFolder.source.user}";
              path = "${userRoot}/${syncthingFolder.source.mediaDir}";
            in {
              # Set the folder setting
              services.syncthing.settings.folders.${syncthingFolder.name} =
                folderSettingsNixos host syncthingFolder path;

              # Pre-make the folder
              systemd.tmpfiles.settings."40-syncthing-headless-${syncthingFolder.name}" = {
                "${userRoot}".d = {
                  user = cfg.user;
                  group = cfg.group;
                  mode = "0750";
                };
                "${path}".d = {
                  user = cfg.user;
                  group = cfg.group;
                  mode = "2770";
                };
              };
            };
          };
      };
    };
  };
}

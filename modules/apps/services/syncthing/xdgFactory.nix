# Factory functions for synching xdg directories of users.
# Defaults to hardcoded directories in darwin,
# Allows specifying "pretty" names variants
{lib, ...}: {
  flake.factory.syncthingXdg = let
    # Helper function for capitalization
    capitalize = s:
      if s == ""
      then ""
      else (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 (builtins.stringLength s) s);
    # Enum for what's possible, and the darwin directory mapping
    userDirs = {
      desktop = {
        default = "Desktop";
        darwin = "Desktop";
      };
      documents = {
        default = "Documents";
        darwin = "Documents";
      };
      download = {
        default = "Downloads";
        darwin = "Downloads";
      };
      music = {
        default = "Music";
        darwin = "Music";
      };
      pictures = {
        default = "Pictures";
        darwin = "Pictures";
      };
      projects = {
        default = "Projects";
        darwin = "Projects";
      };
      templates = {
        default = "Templates";
        darwin = "Templates";
      };
      videos = {
        default = "Videos";
        darwin = "Movies";
      };
    };
    allowedUserDirs = builtins.attrNames userDirs;
    validateUserDir = userDir:
      if lib.hasAttr userDir userDirs
      then userDir
      else
        throw ''
          syncthingXDG: invalid userDir '${userDir}'.
          Expected one of: ${lib.concatStringsSep ", " allowedUserDirs}
        '';
  in
    {
      userDir,
      userDirPretty ? userDirs.${validateUserDir userDir}.default,
      nameUser,
      aliasUser ? nameUser,
      nameUserPretty ? (capitalize aliasUser),
      syncName ? "${aliasUser}-${userDir}",
      sharedHosts ? [],
      perHost ? {},
      ...
    }: let
      userDir' = validateUserDir userDir;
      userDirDarwin = userDirs.${userDir'}.darwin;
    in {
      # Modules for setting up syncthing with XDG directories

      # Folder definitions for our user to share
      generic.syncthing = {
        lib,
        config,
        ...
      }: let
        hostName = config.networking.hostName;
      in {
        config = lib.mkMerge [
          {
            services.syncthing.settings.folders."${syncName}" = {
              enable = lib.mkOverride 1400 false;
              label = "${nameUserPretty} ${userDirPretty}";
              id = "${nameUserPretty}_${userDirPretty}";
              type = "sendreceive";
              devices = lib.filter (device: device != hostName) sharedHosts;
              versioning = {
                type = "trashcan";
                params = {cleanoutDays = "60";};
              };
            };
          }
          (
            lib.mkIf (lib.elem hostName sharedHosts) {
              services.syncthing.settings.folders."${syncName}" =
                {
                  enable = lib.mkDefault true;
                }
                // (lib.attrByPath [hostName] {} perHost);
            }
          )
        ];
      };

      # Folder location for darwin and hm-standalone settings
      homeManager.syncthing = {pkgs, ...}: {
        services.syncthing.settings.folders."${syncName}".path =
          if pkgs.stdenv.hostPlatform.isDarwin
          then "~/${userDirDarwin}"
          else "~/${userDirPretty}";
      };

      # Folder location for nixos settings
      nixos.syncthing = {
        config,
        lib,
        ...
      }: let
        targetDir = "${config.services.syncthing.dataDir}/${nameUserPretty}/${userDirPretty}";
      in {
        config = lib.mkMerge [
          {
            # Sync to the directory
            services.syncthing.settings.folders."${syncName}".path = targetDir;
          }
          (
            lib.mkIf (lib.hasAttrByPath ["users" "users" "${nameUser}"] config) {
              # Drop a symlink if user is enabled
              home-manager.users."${nameUser}".imports = [
                ({
                  config,
                  lib,
                  ...
                }: let
                  removeSuffixPath = str:
                    if str == null
                    then null
                    else
                      str
                      |> toString
                      |> lib.removeSuffix "/";
                  normalizePrefixPath = str:
                    str
                    |> toString
                    |> lib.removeSuffix "/"
                    |> (s: "${s}/");
                  homePrefix = config.home.homeDirectory |> normalizePrefixPath;
                  homeFileTarget =
                    config
                    |> (lib.attrByPath ["xdg" "userDirs" userDir] null)
                    |> removeSuffixPath
                    |> (path:
                      if path != null && lib.hasPrefix homePrefix path
                      then lib.removePrefix homePrefix path
                      else null)
                    |> (path:
                      if path != null && path != ""
                      then path
                      else userDirPretty);
                in {
                  home.file."${homeFileTarget}" = {
                    source = config.lib.file.mkOutOfStoreSymlink "${targetDir}";
                    force = true;
                  };
                })
              ];
            }
          )
        ];
      };
    };
}

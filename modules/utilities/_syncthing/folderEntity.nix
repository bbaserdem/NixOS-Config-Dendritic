# Den folder entity registry for syncthing
{
  config,
  lib,
  flib,
  inputs,
  ...
}: let
  schemaLib =
    (inputs.den.lib {
      inherit inputs lib config;
    }).schema;
  reservedSettings = [
    "devices"
    "enable"
    "id"
    "ignorePatterns"
    "label"
    "path"
  ];
  settingsType =
    lib.types.addCheck
    (lib.types.attrsOf lib.types.unspecified)
    (
      settings:
        builtins.all
        (name: !(builtins.hasAttr name settings))
        reservedSettings
    );
  globalIgnoreDefault = ''
    // Global stignore

    // Do not ignore any Stignore folders
    !/Stignore
    !/Stignore/*

    // Do not track thumbnaails
    .thumbnails
    .thumbnails/**

    // Do not track any VCS
    (?d).git
    (?d).gitmodules
    (?d).jj

    // OS Junk, trash directories
    .Trash-*
    (?d).DS_Store
    .localized
  '';
in {
  # Syncthing topology is to be controlled by den
  # Syncthing folders are entities in den; they are records for what they are
  # We define them as entities
  options = {
    den = {
      syncthingFolders =
        schemaLib.mkInstanceRegistry
        config.den.schema.syncthingFolder
        {
          strict = true;
          description = "Fleet-wide Syncthing folder topology";
        };
    };
  };

  config = {
    den.schema.syncthingFolder = {
      config,
      lib,
      ...
    }: {
      options = {
        id = lib.mkOption {
          type = lib.types.str;
          default = config.name;
          description = "Stable syncthing protocol identity.";
        };

        label = lib.mkOption {
          type = lib.types.str;
          default = config.name;
          description = "Human-readable Syncthing folder label.";
        };

        source = lib.mkOption {
          description = "Resource record for this folder";
          type = lib.types.submodule {
            options = {
              kind = lib.mkOption {
                type = lib.types.enum [
                  "media"
                  "shared"
                  "provided"
                ];
                description = "Resource type of this folder";
              };
              user = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "User owning the media directory resource.";
              };
              mediaDir = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "User's media directory name for this folder.";
              };
              resource = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Logical resource exported by external aspect.";
              };
            };
          };
          apply = source:
            if
              source.kind
              == "media"
              && source.user != null
              && source.mediaDir != null
              && source.resource == null
            then source
            else if
              source.kind
              == "shared"
              && source.user == null
              && source.mediaDir == null
              && source.resource == null
            then source
            else if
              source.kind
              == "provided"
              && source.user == null
              && source.mediaDir == null
              && source.resource != null
            then source
            else
              throw ''
                Invalid source type for den.syncthingFolders.${config.name}

                - media requires `user`, `mediaDir`
                - shared can't take additional fields
                - provided requires `resource`
              '';
        };

        endpoints = lib.mkOption {
          description = "Host endpoints that this folder will be synced to.";
          default = {};
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              ignore = lib.mkOption {
                type = lib.types.lines;
                default = "";
                description = "Host-specific ignore patterns";
              };
              settings = lib.mkOption {
                type = settingsType;
                default = {};
                description = "Host-specific Syncthing folder settings.";
              };
            };
          });
        };

        ignore = lib.mkOption {
          type = lib.types.lines;
          default = globalIgnoreDefault;
          description = "Global ignore patterns for this folder.";
        };
        settings = lib.mkOption {
          type = settingsType;
          default = {};
          description = "Syncthing folder default settings.";
        };
      };
    };

    # Factory function to initialize default user media aspects
    factory.mkSyncthingMediaFolders = userName: folders: (
      folders
      |> map (
        dir:
          lib.nameValuePair
          "${userName}-${dir}"
          {
            label = "${flib.capitalize userName} ${flib.capitalize dir}";
            source = {
              kind = "media";
              user = userName;
              mediaDir = dir;
            };
          }
      )
      |> builtins.listToAttrs
    );
  };
}

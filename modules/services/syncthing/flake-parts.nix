# Syncthing; flake-parts configuration
{
  inputs,
  lib,
  config,
  ...
}: let
  syncthingUsers = config.localConfig.syncthing.users;
in {
  config.flake.modules = {
    # Initialize the generic module.
    # Generic syncthing module will contain ALL the folder/host definitions
    # Along with cross/context sharable settings
    generic.syncthing = {...}: {};

    # NixOS module should pull in generic module
    nixos.syncthing = {
      lib,
      config,
      options,
      ...
    }: {
      # Import module
      imports = [
        inputs.self.modules.generic.syncthing
      ];
      # Dispatch home-manager module to enabled users
      config = lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) {
        home-manager.users =
          syncthingUsers
          |> lib.mapAttrsToList (
            user: userCfg:
              lib.mkIf (
                userCfg.enable
                && (config.users.users.${user}.enable or false)
              ) {
                "${user}".imports = [
                  inputs.self.modules.homeManager.syncthing
                ];
              }
          )
          |> lib.mkMerge;
      };
    };

    # Darwin module; enable syncthing only for the "mainUser"
    darwin.syncthing = {
      lib,
      options,
      config,
      ...
    }: {
      config =
        lib.optionalAttrs (
          (lib.hasAttrByPath ["local" "mainUser"] options)
          && (lib.hasAttrByPath ["home-manager"] options)
        ) {
          home-manager.users = lib.mkIf (config.local.mainUser != null) {
            "${config.local.mainUser}".imports = [
              # Dispatch home-manager module here
              inputs.self.modules.homeManager.syncthing
            ];
          };
        };
    };

    # HomeManager module; used for both HM standalone and generic user config
    homeManager.syncthing = {...}: {
      imports = [
        inputs.self.modules.generic.syncthing
      ];
    };
  };

  # Flake-parts options definition
  # Syncthing topology/setup is stored in config.localConfig.syncthing
  options.localConfig.syncthing = let
    # Joint ignore type option to dispatch stignore lines
    ignoreType = lib.types.submodule {
      options = {
        global = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Ignore pattern applied in all host contexts for this declaration.";
        };
        hosts = lib.mkOption {
          type = lib.types.attrsOf lib.types.lines;
          default = {};
          description = "Host specific ignore patterns";
        };
      };
    };
    # XDG folder types
    xdgType = lib.types.submodule {
      options = {
        hosts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Hosts to share this xdg folder with";
          default = [];
        };
        ignore = lib.mkOption {
          type = ignoreType;
          default = {};
        };
      };
    };
    # User that will be using the folders specification; using xdg dirs
    userType = lib.types.submodule {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable using syncthing with this user";
        };
        xdg = lib.mkOption {
          type = lib.types.attrsOf xdgType;
          default = {};
        };
      };
    };
    # Host specification
    hostType = lib.types.submodule {
      options = {
        id = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Public ID of the host";
        };
      };
    };
    # Folder specification
    folderType = lib.types.submodule {
      options = {
        owner = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = ''
            Username for the proper owner of this directory.

            If provided, the generated folder root will have ownership and ACL set.
            (If a certain context does not have that user, owner will remain syncthing)

            If this folder is shared to a darwin or standalone hm context,
            This option won't have any effect.
          '';
          default = null;
        };
        path = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Filepath that this folder should exist at.
            Path should be relative to HOME

            This option only works in darwin or standalone HM contexts.
            Has no effect on NixOS context, all paths are put under services.syncthing.dataDir

            If this option is not provided, then the target directory will be ~/Syncthing/<Folder>
          '';
        };
        hosts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Hosts to share this folder with";
        };
        ignore = lib.mkOption {
          type = ignoreType;
          default = {};
        };
      };
    };
  in {
    # Global application of ignore files
    ignore = lib.mkOption {
      type = ignoreType;
      default = {};
    };
    # Global declaration of all hosts
    hosts = lib.mkOption {
      type = lib.types.attrsOf hostType;
      default = {};
    };
    # Global declaration of users
    users = lib.mkOption {
      type = lib.types.attrsOf userType;
      default = {};
    };
    # Global folder declarations
    folders = lib.mkOption {
      type = lib.types.attrsOf folderType;
      default = {};
    };
  };
}

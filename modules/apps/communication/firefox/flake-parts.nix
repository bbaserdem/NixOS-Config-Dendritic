# Flake-Parts option definitions for firefox config
{lib, ...}: let
  packageListType = lib.types.oneOf [
    (lib.types.listOf lib.types.package)
    (lib.types.functionTo (lib.types.listOf lib.types.package))
  ];

  extensionsType = lib.types.submodule {
    options = {
      force = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to force replace managed extension state.";
      };

      packages = lib.mkOption {
        type = packageListType;
        default = [];
        description = ''
          Firefox extension packages, or a function returning them.

          Function form is intended for system-dependent packages:
            {pkgs, lib, ...}: with pkgs.nur.repos.rycee.firefox-addons; [ ... ]
        '';
      };

      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Declarative per-extension settings keyed by extension ID.";
      };

      exhaustivePermissions = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      exactPermissions = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  containerType = lib.types.submodule ({name, ...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
      };

      id = lib.mkOption {
        type = lib.types.ints.unsigned;
        description = "Unique Firefox container ID within the profile.";
      };

      icon = lib.mkOption {
        type = lib.types.str;
        default = "circle";
      };

      color = lib.mkOption {
        type = lib.types.str;
        default = "blue";
      };
    };
  });

  profileType = lib.types.submodule ({...}: {
    options = {
      id = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = null;
        description = "Firefox profile ID. If null, the dispatcher must assign one.";
      };

      isDefault = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };

      search = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };

      extensions = lib.mkOption {
        type = extensionsType;
        default = {};
      };

      containers = lib.mkOption {
        type = lib.types.attrsOf containerType;
        default = {};
      };
    };
  });

  firefoxType = lib.types.submodule {
    options = {
      global = {
        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
        };

        search = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
        };

        extensions = lib.mkOption {
          type = extensionsType;
          default = {};
        };

        nativeMessagingHosts = lib.mkOption {
          type = packageListType;
          default = [];
        };
      };

      profiles = lib.mkOption {
        type = lib.types.attrsOf profileType;
        default = {};
      };
    };
  };
in {
  options.localConfig.users = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options.firefox = lib.mkOption {
        type = firefoxType;
        default = {};
        description = "Declarative Firefox configuration for this user.";
      };
    });
  };
}

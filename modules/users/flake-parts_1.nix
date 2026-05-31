# User generation setup
{
  inputs,
  config,
  lib,
  ...
}: let
  users = config.localConfig.users;
  userType = lib.types.submodule ({name, ...}: {
    options = {
      homeManager = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
      normalUser = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      admin = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      nixTrusted = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      home = {
        linux = lib.mkOption {
          type = lib.types.str;
          default = "/home/${name}";
        };
        darwin = lib.mkOption {
          type = lib.types.str;
          default = "/Users/${name}";
        };
      };
    };
  });
  hostNameLoadingModule = {osConfig, ...}: {networking.hostName = osConfig.networking.hostName;};
in {
  options = {
    localConfig.users = lib.mkOption {
      type = lib.types.attrsOf userType;
      default = {};
    };
  };

  config = {
    flake.modules = {
      # Generate individual configs for each context

      # Nixos context
      nixos =
        {
          # By default, disable all users
          default = {lib, ...}: {
            users.users =
              users
              |> lib.mapAttrs (_user: _userCfg: {
                enable = lib.mkOverride 950 false;
              });
          };
        }
        // (
          # Create user config modules for all
          users
          |> lib.mapAttrs' (user: userCfg: {
            name = user;
            value = {
              lib,
              options,
              ...
            }: {
              config = lib.mkMerge [
                {
                  users.users.${user} = {
                    enable = lib.mkOverride 900 true;
                    isNormalUser = userCfg.normalUser;
                    home = userCfg.home.linux;
                    extraGroups = lib.optionals userCfg.admin ["wheel"];
                  };
                }
                (
                  lib.mkIf userCfg.nixTrusted {
                    nix.settings.trusted-users = [user];
                  }
                )
                (
                  lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) (
                    lib.mkIf userCfg.homeManager.enable {
                      home-manager.users.${user}.imports = [
                        inputs.self.modules.homeManager.${user}
                        hostNameLoadingModule
                      ];
                    }
                  )
                )
              ];
            };
          })
        );

      # Darwin context
      darwin =
        users
        |> lib.mapAttrs' (user: userCfg: {
          name = user;
          value = {
            lib,
            options,
            ...
          }: {
            config = lib.mkMerge [
              {
                users.users."${user}" = {
                  home = userCfg.home.darwin;
                  isHidden = false;
                };
              }
              (
                # Enable home-manager config if option exists, and enabled
                lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) (
                  lib.mkIf userCfg.homeManager.enable {
                    home-manager.users."${user}".imports = [
                      inputs.self.modules.homeManager."${user}"
                      hostNameLoadingModule
                    ];
                  }
                )
              )
            ];
          };
        });

      # Home-manager module init
      homeManager =
        users
        |> lib.mapAttrs' (user: _userCfg: {
          name = user;
          value = {...}: {
            config = {
              home.username = user;
            };
          };
        });
    };
  };
}

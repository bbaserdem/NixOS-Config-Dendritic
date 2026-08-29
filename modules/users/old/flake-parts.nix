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
      group = lib.mkOption {
        type = lib.types.str;
        default = "users";
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
                  enable = true;
                  isNormalUser = userCfg.normalUser;
                  group = userCfg.group;
                  home = userCfg.home.linux;
                  extraGroups = lib.optionals userCfg.admin ["wheel"];
                };
              }
              (
                lib.mkIf (userCfg.normalUser) {
                  users.users.${user} = {
                    isNormalUser = true;
                    isSystemUser = false;
                  };
                }
              )
              (
                lib.mkIf (! userCfg.normalUser) {
                  users.users.${user} = {
                    isNormalUser = false;
                    isSystemUser = true;
                  };
                }
              )
              (
                lib.mkIf userCfg.nixTrusted {
                  nix.settings.trusted-users = [user];
                }
              )
              (
                lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) (
                  lib.mkIf userCfg.homeManager.enable (lib.mkMerge [
                    {
                      home-manager.users.${user}.imports = [
                        inputs.self.modules.homeManager.${user}
                        hostNameLoadingModule
                      ];
                    }
                    (lib.optionalAttrs (lib.hasAttrByPath ["local" "hm" "users"] options) {
                      local.hm.users.${user} = true;
                    })
                  ])
                )
              )
            ];
          };
        });

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
                  lib.mkIf userCfg.homeManager.enable (lib.mkMerge [
                    {
                      home-manager.users."${user}".imports = [
                        inputs.self.modules.homeManager."${user}"
                        hostNameLoadingModule
                      ];
                    }
                    (lib.optionalAttrs (lib.hasAttrByPath ["local" "hm" "users"] options) {
                      local.hm.users.${user} = true;
                    })
                  ])
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

# Lutris configuration
{
  inputs,
  den,
  lib,
  flib,
  ...
}: {
  # Den wiring for lutris
  den = {
    schema = {
      host = {
        includes = [
          den.aspects.gaming.policies.lutris-host-dispatch
        ];
        # New options under gaming metadata for steam
        imports = [
          {
            options = {
              gaming = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    # Steam settings
                    lutris = lib.mkOption {
                      description = "Lutris options";
                      default = {};
                      type = lib.types.submodule {
                        options = {
                          enable = lib.mkOption {
                            description = "Enable lutris on this host";
                            default = true;
                            type = lib.types.bool;
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          }
        ];
      };
      user = {
        includes = [
          den.aspects.gaming.policies.lutris-user-dispatch
        ];
      };
    };

    # Aspect for setting steam
    aspects.gaming = {
      # Policies for dispatching
      policies = {
        lutris-host-dispatch = {host, ...}:
          lib.optional
          (host.gaming.enable && host.gaming.lutris.enable)
          (den.lib.policy.include den.aspects.gaming._.lutris);
        lutris-user-dispatch = {
          host,
          user,
          ...
        }:
          lib.optional
          ( # This dispatch is conditional on the games being enabled on this host
            (builtins.elem "games" user.classes)
            && host.gaming.enable
            && host.gaming.lutris.enable
          )
          (den.lib.policy.include den.aspects.gaming._.lutris._.to-users);
      };

      provides.lutris = {
        name = "gaming/lutris";
        # Lutris only has userspace behavior
        # Host-specific configuration
        provides.to-users = {
          user,
          host,
        }: {
          name = "gaming/lutris(${user.userName}@${host.name})";
          homeManager = {lib, ...} @ args: {
            imports = [
              inputs.self.modules.homeManager.lutris-settings
            ];
            config = lib.mkMerge [
              ( # Set lutris' steam package to nixos steam package if possible
                lib.optionalAttrs
                (
                  (args ? osConfig)
                  && host.gaming.steam.enable
                  && (host.class == "nixos")
                )
                {
                  programs.lutris.steamPackage = args.osConfig.programs.steam.package;
                }
              )
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.homeManager.lutris-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "lutris-settings#homeManager";
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      programs.lutris = {
        enable = true;
        # Compat tooling
        protonPackages = with pkgs; [
          proton-ge-bin
        ];
        winePackages = [
          pkgs.wineWow64Packages.stagingFull
        ];
        defaultWinePackage = pkgs.wineWow64Packages.stagingFull;
        extraPackages = [
          pkgs.winetricks
        ];
        # Runners
        runners = {
          wine = {
            settings = {
              runner.system_winetricks = true;
            };
          };
        };
      };
    };
  };
}

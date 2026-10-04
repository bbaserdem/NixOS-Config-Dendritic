# Gaming setup
{
  inputs,
  den,
  lib,
  flib,
  ...
}: {
  den = {
    # Class for user to subscribe to
    classes.games.description = "Set a user up for gaming";

    schema = {
      # For a host, create options for creating a steam share
      host = {
        includes = [
          den.aspects.gaming.policies.gaming-host-dispatch
        ];
        imports = [
          ({...}: {
            options = {
              gaming = lib.mkOption {
                description = "Gaming metadata for this host";
                default = {};
                type = lib.types.submodule {
                  options = {
                    # Generic gaming options
                    enable = lib.mkOption {
                      description = "Enable gaming optimization on this host";
                      default = false;
                      type = lib.types.bool;
                    };
                  };
                };
              };
            };
          })
        ];
      };
      # User schema should include the user dispatch
      user = {
        includes = [
          den.aspects.gaming.policies.gaming-user-dispatch
        ];
      };
    };

    aspects.gaming = {
      name = "gaming";
      # Policy enabling gaming on a host
      policies.gaming-host-dispatch = {host, ...}:
        lib.optionals
        host.gaming.enable
        [
          (den.lib.policy.include den.aspects.gaming)
        ];
      # Dispatch gaming setup for users who opted in
      policies.gaming-user-dispatch = {
        host,
        user,
        ...
      }:
        lib.optionals
        ((builtins.elem "games" user.classes) && (host.gaming.enable))
        [
          (den.lib.policy.include den.aspects.gaming._.user-setup)
        ];

      # Class modules for system configuration
      nixos = {...}: {
        imports = [
          inputs.self.modules.nixos.gaming-settings
        ];
      };

      # Base aspect that provides gaming access
      provides.user-setup = {
        host,
        user,
      }: {
        name = "gaming/user-setup(${user.userName}@${host.name})";
        homeManager = {...}: {
          # Will be deduped by module key if imported multiple times; it's ok
          imports = [
            inputs.self.modules.homeManager.gaming-settings
          ];
        };
        # Add the den users to the gaming group
        user = flib.den.addUserToGroups ["games" "gamemode"];
      };
    };
  };

  # Modules
  flake.modules = {
    nixos.gaming-settings = {pkgs, ...}: {
      key = "gaming-settings#nixos";
      config = {
        # Create the games group (don't create joint GID)
        users.groups.games = {
          name = "games";
        };

        # Enable programs for gaming optimization
        programs = {
          # Enable gamemode; system optimization
          gamemode = {
            enable = true;
            enableRenice = true;
          };
          # Enable opengamepadui; game dashboard
          opengamepadui = {
            enable = true;
            gamescopeSession = {
              enable = true;
            };
          };
        };

        # Add udev rules for gaming devices
        services.udev.packages = with pkgs; [
          game-devices-udev-rules
        ];

        # Need some userspace tools
        environment.systemPackages = with pkgs; [
          gamescope-wsi
          bubblewrap
        ];
      };
    };

    homeManager.gaming-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "gaming-settings#homeManager";
      config = lib.mkMerge [
        ( # Lutris is Linux only
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            # Enable lutris, only in linux
            programs.lutris = {
              enable = true;
            };
          }
        )
      ];
    };
  };
}

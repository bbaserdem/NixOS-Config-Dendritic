# Gaming setup
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    # Class for user to subscribe to
    classes.games.description = "Set a user up for gaming";

    schema = {
      # For a host, create options for creating a steam share
      host = {
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
          den.aspects.applications._.gaming.policies.games-user-dispatch
        ];
      };
    };

    aspects.applications = {
      provides.gaming = {
        # Enable gaming for this user
        policies.games-user-dispatch = {
          host,
          user,
          ...
        }:
          lib.optionals
          ((builtins.elem "games" user.classes) && (host.gaming.enable))
          [
            # Set gaming for this user
            (den.lib.policy.include den.aspects.applications._.gaming._.to-users)
          ];
        # Base aspect that provides gaming access
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/gaming(${user.userName}@${host.name})";
          nixos = {...}: {
            # Will be deduped by module key if imported multiple times; it's ok
            imports = [
              inputs.self.modules.nixos.gaming-settings
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.gaming-settings
            ];
          };
          # Add the den users to the gaming group
          user = {
            lib,
            osConfig,
            ...
          }:
            lib.optionalAttrs (host.class == "nixos") {
              extraGroups =
                [
                  "games"
                  "gamemode"
                ]
                |> builtins.filter (n: lib.hasAttrByPath ["users" "groups" n] osConfig);
            };
        };
      };
    };
  };

  # Modules for gaming setup
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
        ( # Linux only settings
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

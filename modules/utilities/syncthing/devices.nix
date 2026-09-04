# Syncthing; device information is collected by a quirk
{
  inputs,
  lib,
  den,
  flib,
  ...
}: {
  den = {
    # Quirk for collecting device information across the fleet
    quirks.syncthing-devices = {
      description = "Registered syncthing devices";
      # Should emit once per node; with provenance
    };

    # User schema for syncthing enables
    schema.user = {
      # Auto-enable these for user nodes
      includes = [
        den.aspects.syncthing.policies.enable-user-host-node
      ];
      # Options for configuring
      options = {
        syncthing = lib.mkOption {
          description = "Syncthing options for this user";
          default = {};
          type = lib.types.submodule ({...}: {
            options = {
              enable = lib.mkOption {
                description = "Enable syncthing on this node.";
                default = false;
                type = lib.types.bool;
              };
              id = lib.mkOption {
                description = "Public Syncthing node ID";
                default = null;
                type = lib.types.nullOr (
                  lib.types.strMatching
                  "[A-Z2-7]{7}(-[A-Z2-7]{7}){7}"
                );
              };
            };
          });
          # Validity check
          apply = cfg:
            if cfg.enable && (cfg.id == null)
            then throw "Valid syncthing device ID required when enabled"
            else cfg;
        };
      };
    };

    # Aspect for syncthing device setup
    aspects.syncthing = {
      # Registry policy for host-user nodes
      policies = {
        # Emit to quirk a host's data
        enable-user-host-node = {user, ...}:
          lib.optionals (user.syncthing.enable) [
            # Enable syncthing on this user-host node
            (den.lib.policy.include den.aspects.syncthing._.user-host-node)
            (den.lib.policy.include den.aspects.syncthing._.user-host-settings)
            # Collect the quirk information for this user-host scope
            (den.lib.policy.pipe.from den.quirks.syncthing-devices [
              (den.lib.policy.pipe.collectAll (_: true))
              den.lib.policy.pipe.withProvenance
            ])
          ];
      };

      # Emit to quirk node information about the current user-host scope
      provides.user-host-node = {
        host,
        user,
      }: {
        # Collision protection
        name = "syncthing/user-host-node(${user.userName}@${host.name})";

        # Emit our info to quirk
        syncthing-devices = {
          # Device name
          name = "${flib.capitalize user.userName}-${flib.capitalize host.name}";
          id = user.syncthing.id;
          # TODO: Include the port the machine will be running from
        };

        # TODO: Emit our info to local DNS registry quirk as well
      };

      # Emit to quirk node information about the current user-host scope
      provides.user-host-settings = {
        host,
        user,
      }: {
        # Collision protection
        name = "syncthing/user-host-settings(${user.userName}@${host.name})";

        # Load host-specefic information to home-manager
        homeManager = {
          options,
          config,
          lib,
          pkgs,
          syncthing-devices,
          ...
        }: {
          imports = [
            inputs.self.modules.homeManager.syncthing-user-node
          ];
          config = lib.mkMerge [
            (
              # Secrets loading depends on SOPS
              lib.mkIf (options ? sops) {
                # Add secrets to sops
                sops.secrets = let
                  keyConf = {
                    mode = "0440";
                  };
                in {
                  "syncthing/${host.name}/key" = keyConf;
                  "syncthing/${host.name}/cert" = keyConf;
                  "syncthing/${host.name}/restapi" = keyConf;
                };
                # Set syncthing secrets
                services.syncthing = {
                  key = config.sops.secrets."syncthing/${host.name}/key".path;
                  cert = config.sops.secrets."syncthing/${host.name}/cert".path;
                  # API Key setting should be done here when support for this drops
                  # apiKey = config.sops.secrets."syncthing/${host.name}/restapi".path;
                  tray = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {};
                };
              }
            )
            {
              services.syncthing = {
                # TODO: Port settings
                settings = {
                  # Device list, pulled from quirk
                  devices =
                    syncthing-devices
                    # Self is fine for setting our own node name; don't need to filter
                    |> builtins.map (
                      d:
                        lib.nameValuePair
                        "${d.source.user.userName}@${d.source.host.name}"
                        {inherit (d.value) id name;}
                    )
                    |> builtins.listToAttrs;
                };
              };
            }
          ];
        };
      };

      # Configuring the local host machine
      provides.carrier-host-settings = {
        nixos = {...}: {
          # Enable system level syncthing services
          services.syncthing.relay = {
            enable = true;
          };
          # TODO: Open the proper ports used
        };
      };
    };
  };

  flake.modules = {
    # Generic module for enabling syncthing on nixos or on home-manager
    generic.syncthing-settings = {...}: {
      services.syncthing = {
        enable = true;
        settings.options = {
          urAccepted = 3;
          relaysEnabled = true;
          localAnnounceEnabled = true;
        };
      };
    };
    # Nixos module for enabling syncthing side services on nixos
    nixos.syncthing-settings = {...}: {
      services.syncthing = {
        relay = {
          enable = true;
        };
      };
    };
    # Home-manager syncthing settings
    homeManager.syncthing-user-node = {
      lib,
      pkgs,
      ...
    }: {
      config = lib.mkMerge [
        {
          services.syncthing = {
            enable = true;
            settings.options = {
              urAccepted = 3;
              relaysEnabled = true;
              localAnnounceEnabled = true;
            };
          };
        }
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            services.syncthing.tray = {
              enable = true;
              package = pkgs.syncthingtray;
            };
          }
        )
      ];
    };
  };
}

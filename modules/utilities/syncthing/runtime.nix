# Den for enabling syncthing on hosts
{
  lib,
  den,
  inputs,
  ...
}: let
  syncthingPort = 8384;
in {
  den = {
    aspects.syncthing = {
      includes = [
        den.aspects.syncthing.runtimeHost
        den.aspects.syncthing.runtimeHome
      ];

      provides = {
        # Aspect for running syncthing on nixos and darwin
        runtimeHost = {host, ...} @ ctx:
          lib.optionalAttrs (!(ctx ? home)) {
            # Nixos; run as system module
            nixos = {...}: {
              imports = [
                inputs.self.modules.generic.syncthing-runtime
                inputs.self.modules.nixos.syncthing-runtime
              ];
              config = {
                services.syncthing.guiAddress = "127.0.0.1:${toString syncthingPort}";
              };
            };

            # Darwin, dispatch to primaryUsers' home-manager
            darwin = {
              config,
              options,
              lib,
              ...
            }: {
              config = lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) {
                home-manager.users = lib.mkIf (config.system ? primaryUser) {
                  "${config.system.primaryUser}".imports = [
                    inputs.self.modules.homeManager.syncthing-runtime
                    inputs.self.modules.generic.syncthing-runtime
                  ];
                };
              };
            };
          };

        runtimeHome = {home}: {
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.syncthing-runtime
              inputs.self.modules.generic.syncthing-runtime
            ];
          };
        };

        runtimeAddress = {
          localDNS = [
            {
              name = "syncthing";
              port = syncthingPort;
            }
          ];
        };
      };
    };
  };

  flake.modules = {
    # Syncthing module to include in ALL contexts (nixos, home-manager, darwin)
    generic.syncthing-runtime = {...}: {
      services.syncthing = {
        # Launch syncthing on the set port!
        guiAddress = "127.0.0.1:${toString syncthingPort}";
        # Runtime behavior
        settings = {
          # Syncthing global options between nixos-hm modules
          options = {
            urAccepted = 3;
            relaysEnabled = true;
            localAnnounceEnabled = true;
          };
        };
      };
    };

    # Syncthing configuration for nixos (setup system)
    nixos.syncthing-runtime = {config, ...}: {
      # Add syncthing to users group
      users.users.${config.services.syncthing.user}.extraGroups = [
        "users"
      ];

      services.syncthing = {
        enable = true;
        # Open relays and ports
        openDefaultPorts = true;
        relay.enable = true;
      };

      # New files 0660 / dirs 0770
      systemd.services.syncthing.serviceConfig = {
        UMask = "0007";

        # Add new capabilities for ownership
        AmbientCapabilities = [
          "CAP_CHOWN"
          "CAP_FOWNER"
        ];

        # Disable user sandboxing
        PrivateUsers = lib.mkForce false;
        NoNewPrivileges = lib.mkForce false;

        # Allow chown/lchown/fchownat; avoids systemd sandbox blocking ownership
        SystemCallFilter = lib.mkForce [
          "@system-service"
          "@chown"
        ];
      };
    };

    # Home-manager; enable syncthing for the primaryUser
    homeManager.syncthing-runtime = {...}: {services.syncthing.enable = true;};
  };
}

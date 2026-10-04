# Syncthing public relay
{
  den,
  lib,
  inputs,
  ...
}: {
  den = {
    # Host schema for enabling syncthing relay
    schema.host = {
      includes = [
        den.aspects.syncthing.policies.host-relay-dispatch
      ];
      options = {
        networking = lib.mkOption {
          type = lib.types.submodule {
            options = {
              syncthing = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    relay = lib.mkOption {
                      description = "Enable public syncthing relay on this host.";
                      default = false;
                      type = lib.types.bool;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    aspects.syncthing = {
      policies.host-relay-dispatch = {host, ...}:
        lib.optional
        host.networking.syncthing.relay
        (den.lib.policy.include den.aspects.syncthing._.relay);

      provides.relay = {host}: {
        name = "syncthing/relay(@${host.name})";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.syncthing-relay
          ];
        };
        # TODO: Use quirk to open ports
      };
    };
  };

  # Nixos module for enabling syncthing relay
  flake.modules.nixos.syncthing-relay = {...}: {
    key = "syncthing-relay#nixos";
    config = {
      services.syncthing = {
        relay = {
          enable = true;
        };
      };
    };
  };
}

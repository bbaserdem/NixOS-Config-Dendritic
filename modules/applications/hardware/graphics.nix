# Nixos; graphics tooling
{
  den,
  lib,
  ...
}: {
  den = {
    # Host schema to subscribe to certain graphics modules
    schema.host = {
      includes = [
        den.aspects.hardware._.graphics.policies.graphics-host-dispatch
      ];
      options = {
        hardware = lib.mkOption {
          type = lib.types.submodule {
            options = {
              graphics = lib.mkOption {
                description = "Graphics related settings. (NixOS)";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Enable hardware management of graphics.";
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
    };

    # Base aspect, stub for now
    aspects.hardware = {
      provides.graphics = {
        name = "hardware/graphics";
        policies.graphics-host-dispatch = {host, ...}:
          lib.optional
          (host.hardware.graphics.enable && (host.class == "nixos"))
          (den.lib.policy.include den.aspects.hardware._.graphics);
      };
    };
  };
}

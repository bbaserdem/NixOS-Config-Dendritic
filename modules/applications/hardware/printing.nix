# Communicate with printers
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Host config option
    schema.host = {
      includes = [
        den.aspects.hardware._.printing.policies.cups-dispatch
      ];
      options = {
        hardware = lib.mkOption {
          type = lib.types.submodule {
            options = {
              printing = lib.mkOption {
                description = "Printing tools";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Whether to enable CUPS daemon";
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

    # Aspect
    aspects.hardware = {
      provides.printing = {
        name = "hardware/printing";
        # Dispatch policy
        policies.cups-dispatch = {host, ...}:
          lib.optional
          host.hardware.printing.enable
          (den.lib.policy.include den.aspects.hardware._.printing);
        # Module
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.cups-settings
          ];
        };
        # TODO: Open firewall with our quirk
      };
    };
  };

  flake.modules.nixos.cups-settings = {...}: {
    key = "cups-settings#nixos";
    config = {
      services.printing = {
        enable = true;
        # Enable printer sharing
        listenAddresses = ["*:631"];
        allowFrom = ["all"];
        browsing = true;
        defaultShared = true;
        openFirewall = true;
      };
    };
  };
}

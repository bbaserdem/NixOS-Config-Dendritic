# Bluetooth
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
        den.aspects.hardware._.bluetooth.policies.bluetooth-host-dispatch
      ];
      options = {
        hardware = lib.mkOption {
          type = lib.types.submodule {
            options = {
              bluetooth = lib.mkOption {
                description = "Bluetooth tools";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Whether to enable bluetooth";
                      default = false;
                      type = lib.types.bool;
                    };
                    disableHSP = lib.mkOption {
                      description = "Whether to disable HSP switching";
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

    aspects.hardware = {
      provides.bluetooth = {
        name = "hardware/bluetooth";
        # Dispatch policy
        policies.bluetooth-host-dispatch = {host, ...}: (
          lib.optionals
          host.hardware.bluetooth.enable
          (
            [
              (den.lib.policy.include den.aspects.hardware._.bluetooth)
            ]
            ++ (
              lib.optional host.hardware.bluetooth.disableHSP
              (den.lib.policy.include den.aspects.hardware._.bluetooth._.disable-hsp)
            )
          )
        );
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.bluetooth-settings
          ];
        };
        # HSP disable
        provides.disable-hsp = {
          name = "hardware/bluetooth/disable-hsp";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.bluetooth-hspdisable
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.nixos = {
    bluetooth-settings = {...}: {
      key = "bluetooth-settings#nixos";
      config = {
        hardware.bluetooth.enable = true;
      };
    };
    bluetooth-hspdisable = {...}: {
      key = "bluetooth-hspdisable#nixos";
      config = {
        # Disable HSP switching in wireplumber
        services.pipewire.wireplumber.extraConfig."11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = false;
          };
        };
      };
    };
  };
}

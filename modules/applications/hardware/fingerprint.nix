# Fingerprint functionality; fprintd settings
{
  lib,
  den,
  inputs,
  ...
}: {
  # Den
  den = {
    # Add to host schema ability to punch in fingerprintd settings
    schema.host = {
      # Auto-include the fprintd dispatch
      includes = [
        den.aspects.hardware._.fingerprint.policies.fprintd-host-dispatch
      ];
      options = {
        hardware = lib.mkOption {
          type = lib.types.submodule {
            options = {
              fingerprint = lib.mkOption {
                description = "Options for using and enabling fingerprint daemon";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Enable fingerprintd on this host";
                      default = false;
                      type = lib.types.bool;
                    };
                    tod = lib.mkOption {
                      description = "Whether to enable Touch OEM driver support";
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

    # Aspect to setup fingerprints
    aspects.hardware = {
      provides.fingerprint = {
        name = "hardware/fingerprint";
        # Policy for auto-dispatch
        policies.fprintd-host-dispatch = {host, ...}:
          lib.optionals
          host.hardware.fingerprint.enable
          (
            [
              (den.lib.policy.include den.aspects.hardware._.fingerprint)
            ]
            ++ (
              lib.optional host.hardware.fingerprint.tod
              (den.lib.policy.include den.aspects.hardware._.fingerprint._.fprintd-tod)
            )
          );
        # Aspect module
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.fprintd-settings
          ];
        };
        # TOD-specific aspect module
        provides.fprintd-tod = {
          name = "hardware/fingerprint/fprintd-tod";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.fprintd-tod
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.nixos = {
    fprintd-settings = {lib, ...}: {
      key = "fprintd-settings#nixos";
      config = {
        services.fprintd = {
          enable = true;
          tod.enable = lib.mkDefault false;
        };
      };
    };
    fprintd-tod = {pkgs, ...}: {
      key = "fprintd-tod#nixos";
      config = {
        services.fprintd.tod = {
          enable = true;
          driver = pkgs.libfprint-2-tod1-goodix;
        };
      };
    };
  };
}

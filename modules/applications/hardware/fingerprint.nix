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
        den.aspects.hardware._.fingerprint.policies.fprintd-dispatch
      ];
      imports = [
        ({...}: {
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
        })
      ];
    };

    # Aspect to setup fingerprints
    aspects.hardware = {
      provides.fingerprint = {
        # Policy for auto-dispatch
        policies.fprintd-dispatch = {host, ...}:
          lib.optionals
          host.fingerprint.enable
          (
            [
              (den.lib.policy.include den.aspects.hardware._.fingerprint)
            ]
            ++ (
              lib.optional
              host.fingerprint.tod
              (den.lib.policy.include den.aspects.hardware._.fingerprint._.fprintd-toc)
            )
          );
        # Aspect module
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.fprintd-settings
          ];
        };
        # TOC-specific aspect module
        provides.fprintd-toc = {
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.fprintd-tod
            ];
          };
        };
      };
    };
  };

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

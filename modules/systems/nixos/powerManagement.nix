# Setup for power management in nixos hosts
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
      options = {
        powerManagement = lib.mkOption {
          description = "Options for enabling power management";
          default = {};
          type = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                description = "Enable power management on this host";
                default = false;
                type = lib.types.bool;
              };
              backend = lib.mkOption {
                description = "Power management backend to use";
                default = "ppd";
                type = lib.types.enum [
                  "ppd"
                  "tuned"
                ];
              };
            };
          };
        };
      };
    };

    # Aspect to setup fingerprints
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos.policies.nixos-power-management-dispatch
        ];
        # Policy for auto-dispatch
        policies.nixos-power-management-dispatch = {host, ...}: (
          lib.optionals
          host.powerManagement.enable
          [
            (
              den.lib.policy.include
              den.aspects.system._.nixos._.powerManagement
            )
            (
              den.lib.policy.include
              den.aspects.system._.nixos._.powerManagement._.${host.powerManagement.backend}
            )
          ]
        );

        provides.powerManagement = {
          name = "system/nixos/powerManagement";
          # Aspect module
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-power
            ];
          };
          # Load specific backend modules
          provides.ppd = {
            name = "system/nixos/powerManagement/ppd";
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.nixos-ppd
              ];
            };
          };
          provides.tuned = {
            name = "system/nixos/powerManagement/tuned";
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.nixos-tuned
              ];
            };
          };
        };
      };
    };
  };

  flake.modules.nixos = {
    # General enabling of power management
    nixos-power = {pkgs, ...}: {
      key = "nixos-power#nixos";
      config = {
        powerManagement = {
          enable = true;
          # Service enabling is only for auto-tuning at startup; we don't want this auto-enabled
          powertop.enable = false;
        };

        services.upower = {
          enable = true;
          usePercentageForPolicy = true;
          percentageLow = 20;
          percentageCritical = 10;
          percentageAction = 5;
          criticalPowerAction = "HybridSleep";
        };

        # We do want to have the tools in userspace though
        environment.systemPackages = with pkgs; [
          powertop
        ];
      };
    };
    # Power Profiles Daemon setup
    nixos-ppd = {...}: {
      key = "nixos-ppd#nixos";
      config = {
        services = {
          # Enable PPD
          power-profiles-daemon.enable = true;
          # Disable other endpoints
          tuned.enable = false;
          auto-cpufreq.enable = false;
          tlp.enable = false;
        };
      };
    };
    # Tuned setup
    nixos-tuned = {lib, ...}: {
      key = "nixos-tuned#nixos";
      config = {
        services = {
          # Enable tuned with ppd compatibility
          tuned = {
            enable = true;
            ppdSupport = true;
          };
          # Disable other systems
          power-profiles-daemon.enable = false;
          auto-cpufreq.enable = false;
          # Needs force, nixos enable- w/out ppd
          tlp.enable = lib.mkForce false;
        };
      };
    };
  };
}

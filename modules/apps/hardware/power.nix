# Powertop; cpu power monitoring/tuning
{...}: {
  flake.modules.nixos.power = {
    pkgs,
    config,
    lib,
    ...
  }: {
    # Customize backend usage
    options = {
      local.powerManagement = {
        backend = lib.mkOption {
          type = lib.types.enum [
            "ppd"
            "tuned"
          ];
          default = "tuned";
          description = "Power profile management backend to use";
        };
      };
    };

    # System configuration
    config = lib.mkMerge [
      {
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
      }
      (
        lib.mkIf (config.local.powerManagement.backend == "ppd") {
          services = {
            # Enable PPD
            power-profiles-daemon.enable = true;
            # Disable other endpoints
            tuned.enable = false;
            auto-cpufreq.enable = false;
            tlp.enable = false;
          };
        }
      )
      (
        # Use tuned for power management
        lib.mkIf (config.local.powerManagement.backend == "tuned") {
          services = {
            tuned = {
              enable = true;
              ppdSupport = true;
            };
            # Disable other systems
            power-profiles-daemon.enable = false;
            auto-cpufreq.enable = false;
            tlp.enable = lib.mkForce false; # Needs force, nixos enable- w/out ppd
          };
        }
      )
    ];
  };
}

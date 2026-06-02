# Su-ana hardware config related to frame.work laptop
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {
    config,
    lib,
    options,
    ...
  }: {
    # Import hardware optimizations
    imports = [
      inputs.hardware.nixosModules.framework-13-7040-amd
    ];

    config = {
      # Framework is optimized for ppd, use that for default for now
      local.powerManagement.backend = "ppd";

      # Fan control module
      hardware.fw-fanctrl = {
        enable = true;
        config = {
          defaultStrategy = "medium";
          strategyOnDischarging = "lazy";
          strategies = {
            "lazy" = {
              fanSpeedUpdateFrequency = 5;
              movingAverageInterval = 30;
              speedCurve = [
                {
                  temp = 0;
                  speed = 15;
                }
                {
                  temp = 50;
                  speed = 15;
                }
                {
                  temp = 65;
                  speed = 25;
                }
                {
                  temp = 70;
                  speed = 35;
                }
                {
                  temp = 75;
                  speed = 50;
                }
                {
                  temp = 85;
                  speed = 100;
                }
              ];
            };
          };
        };
      };

      boot = {
        kernelModules = [
          "framework-laptop-kmod"
        ];
        extraModulePackages = with config.boot.kernelPackages; [
          framework-laptop-kmod
        ];
      };

      # A systemd bug?
      systemd.services.systemd-logind.environment."SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK" = "1";
    };
  };
}

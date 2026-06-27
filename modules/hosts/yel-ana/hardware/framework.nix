# Su-ana hardware config related to frame.work laptop
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {pkgs, ...}: {
    # Import hardware optimizations
    imports = [
      inputs.hardware.nixosModules.framework-13-7040-amd
    ];

    config = {
      # Framework is optimized for ppd, use that for default for now
      local.powerManagement.backend = "ppd";

      # Explicitly disable fingerprint; enabled by default by nixos-hardware
      services.fprintd.enable = false;

      # Framework specific audio enhancement
      hardware.framework.laptop13.audioEnhancement.enable = true;

      # Framework battery health; even when it's really bad right now
      systemd.services.framework-charge-limit = {
        description = "Set Framework battery charge limit";
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.framework-tool}/bin/framework_tool --charge-limit 80";
          RemainAfterExit = true;
        };
      };

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

      # A systemd bug?
      # TODO: IF everything works without this, remove it.
      # systemd.services.systemd-logind.environment."SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK" = "1";
    };
  };
}

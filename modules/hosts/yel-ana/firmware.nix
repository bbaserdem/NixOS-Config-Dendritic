# Su-ana firmware configuration
{inputs, ...}: {
  den = {
    # Entity record
    hosts.yel-ana = {
      boot.microcode = "amd";
    };

    # Module dispatch
    aspects.yel-ana.nixos = {...}: {
      imports = [
        inputs.self.modules.nixos.yel-ana-firmware
      ];
    };
  };

  # Module
  flake.modules.nixos = {
    yel-ana-firmware = {pkgs, ...}: {
      key = "yel-ana-firmware#nixos";
      imports =
        # Framework module
        [
          inputs.hardware.nixosModules.framework-13-7040-amd
        ]
        # Load chaotic modules for cachyos kernel
        ++ (with inputs.chaotic.nixosModules; [
          nyx-cache
          nyx-overlay
          nyx-registry
        ]);

      config = {
        # System behavior

        # Framework specific audio enhancement
        hardware.framework.laptop13.audioEnhancement.enable = true;

        # Boot params
        boot = {
          # Avoid swap if we can
          kernel.sysctl."vm.swappiness" = 0;
          # Virtualization kernel module, for cross comp
          kernelModules = ["kvm-amd"];
          kernelParams = ["amd_pstate=active"];
        };

        # Framework battery health (my battery is pretty bad; but this couldn't hurt)
        systemd.services.framework-charge-limit = {
          description = "Set Framework battery charge limit";
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.framework-tool}/bin/framework_tool --charge-limit 80";
            RemainAfterExit = true;
          };
        };

        # Use cachyos kernel
        boot.kernelPackages = pkgs.linuxPackages_cachyos-lto-znver4;

        # Additional kernels to have
        specialisation."Fallback Kernel" = {
          configuration = {
            pkgs,
            lib,
            ...
          }: {
            boot.kernelPackages = lib.mkOverride 900 pkgs.linuxPackages_latest;
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
      };
    };
  };
}

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
        # However tweak this because the output volume is set very low
        hardware.framework.laptop13.audioEnhancement = {
          enable = true;
          # hideRawDevice = false;
        };
        services.pipewire.wireplumber.extraConfig."51-framework-audio-fix" = {
          "monitor.alsa.rules" = [
            {
              # Remove the -23.25 dB default Wireplumber volume for the hardware
              matches = [{"device.name" = "alsa_card.pci-0000_c1_00.6";}];
              actions.update-props."device.routes.default-sink-volume" = 1.0;
            }
          ];
          "stream.rules" = [
            {
              # Force DSP backend to 100%
              matches = [
                {
                  "node.name" = "audio_effect.laptop-convolver";
                  "media.class" = "Stream/Output/Audio";
                }
              ];
              actions.update-props = {
                "state.restore-props" = false;
                "state.restore-target" = false;
                "state.default-volume" = 1.0;
              };
            }
          ];
        };

        # Explicitly disable fingerprnt daemon
        # Need this because framework module uses mkDefault to enable it.
        services.fprintd.enable = false;

        # Boot params
        boot = {
          # Avoid swap if we can; we are laptop
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
            boot.kernelPackages = lib.mkOverride 90 pkgs.linuxPackages_latest;
          };
        };

        # Fan control module
        hardware.fw-fanctrl = {
          enable = true;
          config = {
            # Builtins: laziest | lazy | medium | agile | very-agile | deaf | aeolus
            defaultStrategy = "lazy";
            strategyOnDischarging = "laziest";
          };
        };
      };
    };
  };
}

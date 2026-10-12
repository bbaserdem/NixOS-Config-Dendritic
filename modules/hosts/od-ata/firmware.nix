# Od-Ata firmware configuration
{inputs, ...}: {
  den = {
    # Entity record
    hosts.od-ata = {
      boot.microcode = "intel";
    };
    # Aspect for module dispatch
    aspects.od-ata.nixos = {...}: {
      imports = with inputs.self.modules.nixos; [
        od-ata-firmware
        intel-nuc-firmware
      ];
    };
  };

  flake.modules.nixos.od-ata-firmware = {pkgs, ...}: {
    key = "od-ata-firmware#nixos";
    config = {
      # Kernel configuration
      boot = {
        # Kernel
        # Mainline lts should be fine
        kernelPackages = pkgs.linuxPackages;
        # Parameters
        kernelParams = [
          "i915.enable_guc=2" # jellyfin vaapi/qsv might need it
        ];
        # Avoid swap if we can
        kernel.sysctl."vm.swappiness" = 0;
        # Modules
        initrd = {
          # Detected by nixos-generate-config, available for loading
          availableKernelModules = [
            "ahci"
            "usb_storage"
            "sd_mod"
          ];
          # Force-loaded kernel modules
          kernelModules = [
            "i915"
            "xhci_pci"
            "xhci_hcd"
            "usbhid"
            "hid_generic"
          ];
        };
        # Virtualization module
        kernelModules = [
          "kvm-intel"
        ];
      };
    };
  };

  # TODO: Intel NUC related module; should be externalized
  flake.modules.nixos.intel-nuc-firmware = {
    pkgs,
    lib,
    config,
    ...
  }: {
    key = "intel-nuc-firmware#nixos";
    config = {
      # Hardware related services
      services = {
        # Thermals management
        thermald.enable = true;
        # Montools for disk health
        smartd.enable = true;
        # Trim
        fstrim.enable = true;
        # Firmware upgrades
        fwupd.enable = true;
      };

      hardware = {
        # Enable microcode updates explicitly
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

        # Enable graphics
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-compute-runtime-legacy1
          ];
        };
      };
    };
  };
}

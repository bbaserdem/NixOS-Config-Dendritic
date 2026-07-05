# Od-Ata firmware configuration
{...}: {
  flake.modules.nixos.od-ata = {pkgs, ...}: {
    config = {
      # System behavior

      # Kernel configuration
      boot = {
        # Kernel
        # Mainline should be fine
        kernelPackages = pkgs.linuxPackages_latest;
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
            "xhci_pci"
            "ahci"
            "usbhid"
            "usb_storage"
            "sd_mod"
          ];
          # Detected by nixos-facter; will need this anyway
          kernelModules = [
            "i915"
          ];
        };
        # Virtualization module
        kernelModules = [
          "kvm-intel"
        ];
      };
    };
  };
}

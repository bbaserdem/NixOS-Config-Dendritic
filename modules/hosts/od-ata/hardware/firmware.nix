# Od-Ata firmware configuration
{...}: {
  flake.modules.nixos.od-ata = {pkgs, ...}: {
    config = {
      # System behavior

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
}

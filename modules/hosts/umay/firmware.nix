# Umay firmware configuration
# The module that defines the kernel, initrd and boot config
{...}: {
  flake.modules.nixos.umay = {modulesPath, ...}: {
    # Boot parameters
    boot = {
      # Kernel modules and parameters
      initrd = {
        availableKernelModules = [
          "ataa_pix"
          "uhci_hcd"
          "virtio_pci"
          "sr_mod"
          "virtio_blk"
          "ahci"
          "xhci_pci"
        ];
        kernelModules = [
          "virtio_balloon"
          "virtio_console"
          "virtio_rng"
        ];
      };
      kernelParams = [
        "console=ttyS0,115200"
      ];
      kernelModules = ["kvm-amd"];

      # Boot loader
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
  };
}

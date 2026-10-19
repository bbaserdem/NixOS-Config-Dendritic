# VM firmware configuration for guest nixos OS
# The module that defines the kernel, initrd and boot config
{...}: {
  flake.modules.nixos = {
    virtual-machine = {...}: {
      # Boot parameters
      boot = {
        # Kernel modules and parameters
        initrd = {
          availableKernelModules = [
            "virtio_pci"
            "virtio_blk"
            "virtio_net"
            "virtio_scsi"
            "virtio_balloon"
            "virtio_console"
            "virtio_rng"
            "virtio_gpu"
          ];
          kernelModules = [
            "virtio_balloon"
            "virtio_rng"
          ];
        };

        # Enable support for virtual partitions for host-guest sharing
        supportedFilesystems = {
          virtiofs = true;
        };

        # Boot loader
        loader = {
          systemd-boot.enable = true;
          # Images are read-only
          efi.canTouchEfiVariables = false;
        };
      };
    };

    # AMD64 specific settings
    virtual-machine-amd = {...}: {
      boot = {
        initrd.availableKernelModules = [
          "ata_piix"
          "uhci_hcd"
        ];
        kernelParams = [
          "console=ttyS0,115200"
        ];
      };
    };

    # ARM specific settings
    virtual-machine-arm = {...}: {
      boot = {
        kernelParams = [
          "console=ttyAMA0"
        ];
      };
    };
  };
}

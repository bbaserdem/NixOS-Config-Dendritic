# Virtual machine filesystem configuration for guest nixos
{...}: {
  flake.modules.nixos = {
    vm = {...}: {
      # File system of qemu image
      # Refer to the builder for default filesystem layout
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/make-disk-image.nix
      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/nixos";
          autoResize = true;
          fsType = "ext4";
        };
        "/boot" = {
          device = "/dev/disk/by-label/ESP";
          fsType = "vfat";
        };
      };

      # Grow the GPT to the qcow2 image size
      boot.growPartition = true;
    };
  };
}

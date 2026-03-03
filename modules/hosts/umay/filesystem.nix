# Umay filesystem configuration
# While other hosts use disko for filesystem config, it's overkill for a VM
{...}: {
  flake.modules.nixos.umay = {...}: {
    # File system of qemu image
    # Refer to the builder for filesystem layout
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/make-disk-image.nix
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos-umay";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
      };
    };
  };
}

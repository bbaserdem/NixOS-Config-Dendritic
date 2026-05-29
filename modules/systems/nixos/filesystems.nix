# Filesystem settings
{inputs, ...}: {
  flake.modules.nixos.nixos = {pkgs, ...}: {
    imports = [
      inputs.self.modules.generic.filesystems
      inputs.disko.nixosModules.disko
    ];

    # Enable ZFS
    boot.supportedFilesystems = [
      "zfs"
    ];

    # Packages handling filesystems
    environment.systemPackages = with pkgs; [
      # Partition management
      parted
      ntfs3g
      gparted
      # Permissions
      acl
      # BTRFS tools
      btrfs-progs
      btrfs-assistant
      btrfs-heatmap
      snapper
      # ZFS management
      zfs
    ];
  };
}

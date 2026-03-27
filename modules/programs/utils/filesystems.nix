# Filesystem settings
{...}: {
  flake.modules.nixos.filesystems = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      btrfs-progs
      btrfs-assistant
      btrfs-heatmap
      snapper
      e2fsprogs
      ntfs3g
      parted
      gparted
      gptfdisk
      sshfs
      smartmontools
    ];
  };
}

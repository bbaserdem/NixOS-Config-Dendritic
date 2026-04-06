# Filesystem settings
{...}: {
  flake.modules.nixos.filesystems = {pkgs, ...}: {
    # Enable udisks for hardware detection
    services.udisks2 = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      acl
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

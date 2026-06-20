# Filesystem settings
{inputs, ...}: {
  flake.modules.nixos.nixos = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.self.modules.generic.filesystems
      inputs.disko.nixosModules.disko
    ];

    config = {
      # Enable FUSE
      programs.fuse = {
        enable = true;
        userAllowOther = true;
      };

      # File system support
      boot.supportedFilesystems = {
        # Disable zfs; just painful
        zfs = lib.mkForce false;
        # Usual linux filesystems
        btrfs = true;
        ext4 = true;
        xfs = true;
        vfat = true;
        # Flash drives etc.
        f2fs = true;
        exfat = true;
        iso9660 = true;
        # Other OS
        ntfs = true;
        # Runtime basics
        squashfs = true;
        overlay = true;
        tmpfs = true;
      };

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
        # Encrypted fuse filesystems
        gocryptfs
        cryptsetup
      ];
    };
  };
}

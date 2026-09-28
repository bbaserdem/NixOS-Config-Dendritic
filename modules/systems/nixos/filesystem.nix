# Filesystem settings
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.filesystem
        ];
        provides.filesystem = {
          name = "system/nixos/filesystem";
          nixos = {...}: {
            imports = [
              inputs.self.modules.generic.os-filesystem
              inputs.self.modules.nixos.nixos-filesystem
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.nixos.nixos-filesystem = {
    pkgs,
    lib,
    ...
  }: {
    key = "nixos-filesystem#nixos";
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

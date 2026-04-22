# Filesystem settings
{...}: {
  flake.modules = {
    generic.filesystems = {pkgs, ...}: {
      # Cross-platform tooling
      environment.systemPackages = with pkgs; [
        # Disk/Partition Inspection
        smartmontools # Health checks
        gptfdisk # GPT partitioning (gdisk)
        # Linux specific, but metadata in darwin
        e2fsprogs # Ext2/3/4 tools
        # Remote filesystem
        sshfs
        # Modern replacement for tools
        dust # Better du
        bottom # Better top for disk I/O
        lsd # Better ls
      ];
    };

    # Nixos
    nixos.filesystems = {pkgs, ...}: {
      # Enable ZFS
      boot.supportedFilesystems = [
        "zfs"
      ];

      # Enable udisks for hardware detection
      services.udisks2 = {
        enable = true;
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
        # ZFS management
        zfs
      ];
    };

    # Darwin
    darwin.filesystems = {...}: {
      homebrew = {
        casks = [
          "openzfs"
          "macfuse"
        ];
      };
    };
  };
}

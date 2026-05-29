# Filesystem settings
{...}: {
  flake.modules.generic.filesystems = {pkgs, ...}: {
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
}

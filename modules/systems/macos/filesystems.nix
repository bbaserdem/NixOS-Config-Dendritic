# Filesystem settings
{...}: {
  flake.modules.darwin.macos-filesystems = {pkgs, ...}: {
    # Additionale support
    homebrew = {
      casks = [
        "macfuse"
      ];
    };

    # Install fuse filesystem packages
    environment.systemPackages = with pkgs; [
      gocryptfs
      ext4fuse
    ];
  };
}

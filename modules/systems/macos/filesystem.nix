# Filesystem settings
{...}: {
  flake.modules.darwin.macos-filesystem = {pkgs, ...}: {
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

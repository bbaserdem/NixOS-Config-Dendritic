# Filesystem settings
{inputs, ...}: {
  flake.modules.darwin.macos = {pkgs, ...}: {
    imports = [
      inputs.self.modules.generic.filesystems
    ];

    config = {
      # Additionale support
      homebrew = {
        casks = [
          "macfuse"
        ];
      };

      # Install fuse filesystem packages
      environment.systemPackages = with pkgs; [
        gocryptfs
      ];
    };
  };
}

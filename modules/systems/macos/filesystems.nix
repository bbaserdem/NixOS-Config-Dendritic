# Filesystem settings
{inputs, ...}: {
  flake.modules.darwin.macos = {
    imports = [
      inputs.self.modules.generic.filesystems
    ];

    # Additionale support; ZFS
    homebrew = {
      casks = [
        "openzfs"
        "macfuse"
      ];
    };
  };
}

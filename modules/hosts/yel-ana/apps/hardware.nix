# Su-ana userspace configuration
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System configuration

    # Load modules that add hardware support
    imports = with inputs.self.modules.darwin; [
      # Filesystems
      filesystems
    ];
  };
}

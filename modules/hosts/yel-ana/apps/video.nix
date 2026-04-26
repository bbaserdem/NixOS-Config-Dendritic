# Su-ana userspace configuration
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System configuration

    # Load modules that configure the system
    imports = with inputs.self.modules.darwin; [
      # Video suite
      video
      obs
    ];
  };
}

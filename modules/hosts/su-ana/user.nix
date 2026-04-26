# Su-ana system configuration
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System configuration

    # Load modules that configure the system
    imports = with inputs.self.modules.darwin; [
      batuhan
    ];

    config = {
      system = {
        # This option will be removed in the future, don't depend on it
        primaryUser = "batuhan";
        # Our implementation
        mainUser = "batuhan";
      };
    };
  };
}

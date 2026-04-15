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
        primaryUser = "batuhan";
      };
    };
  };
}

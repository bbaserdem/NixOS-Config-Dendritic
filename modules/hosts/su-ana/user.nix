# Su-ana system configuration
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System configuration

    # Load modules that configure the system
    imports = with inputs.self.modules.darwin; [
      batuhan
      wolframite
    ];

    config = {
      #TODO: Remove the system option once it's deprectaed
      system.primaryUser = "batuhan";
      local.mainUser = "batuhan";
    };
  };
}

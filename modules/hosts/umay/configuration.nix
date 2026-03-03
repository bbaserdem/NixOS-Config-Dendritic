# Umay system configuration
# The modules imported by the system module that builds this host
{inputs, ...}: {
  flake.modules.nixos.umay = {...}: {
    imports = with inputs.self.modules.nixos; [
    ];

    # System state version
    system.stateVersion = "25.11";
  };
}

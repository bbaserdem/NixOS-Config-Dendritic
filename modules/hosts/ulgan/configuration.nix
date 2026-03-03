# Umay system configuration
# The modules imported by the system module that builds this host
{inputs, ...}: {
  flake.modules.nixos.ulgan = {...}: {
    imports = with inputs.self.modules.nixos; [
      vm-arm
    ];

    # System state version
    system.stateVersion = "25.11";
  };
}

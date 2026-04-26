# Su-ana system configuration
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {...}: {
    # System configuration

    # Load modules that configure the system
    imports = with inputs.self.modules.nixos; [
      batuhan
    ];
  };
}

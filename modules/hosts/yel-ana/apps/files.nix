# Su-ana userspace apps
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {...}: {
    # Load modules that configure the system
    imports = with inputs.self.modules.nixos; [
      files
      yazi
    ];
  };
}

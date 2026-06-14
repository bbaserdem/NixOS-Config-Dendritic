# Su-ana system configuration
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {...}: {
    # Load modules that configure the system
    imports = with inputs.self.modules.nixos; [
      #---System modules
      secrets
      stylix
      #---Services
      avahi
      networkmanager
      nginx
      samba
    ];
  };
}

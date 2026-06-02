# Su-ana system configuration
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {...}: {
    # System configuration
    networking.hostId = "3c075d00";

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

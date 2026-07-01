# Su-ana system configuration
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {...}: {
    # Load modules that configure the system
    imports = with inputs.self.modules.nixos; [
      #---System modules
      secrets
      stylix
      #---Utility modules
      utility-networkmanager
      #---Services
      avahi
      nginx
      samba
    ];

    config = {
      # We are a desktop computer
      services.avahi.publish.workstation = true;
    };
  };
}

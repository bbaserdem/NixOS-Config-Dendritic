# Od Ata system config
{inputs, ...}: {
  flake.modules.nixos.od-ata = {...}: {
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
  };
}

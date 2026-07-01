# Network manager, for network management
{...}: {
  flake.modules.nixos.utility-networkmanager = {...}: {
    # Enable network manager for networking
    networking.networkmanager.enable = true;
    # Enable timezoned
    services.automatic-timezoned.enable = true;
  };
}

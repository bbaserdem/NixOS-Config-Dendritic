# Network manager, network management
{...}: {
  flake.modules.nixos.networkmanager = {...}: {
    # Enable network manager
    networking.networkmanager.enable = true;
    # Enable timezoned
    services.automatic-timezoned.enable = true;
  };
}

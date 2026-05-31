# Network manager, network management
{...}: {
  flake.modules.nixos.networkmanager = {...}: {
    # Enable network manager
    networking.networkmanager.enable = true;
    # Enable timezoned
    services.automatic-timezoned.enable = true;
  };

  # Factory function to add user to networkmanager
  factory.networkmanagerUser = {user, ...}: {
    nixos.${user} = {...}: {
      config.users.users.${user}.extraGroups = [
        "networkmanager"
        "nm-openvpn"
      ];
    };
  };
}

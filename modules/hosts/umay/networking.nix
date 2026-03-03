# Umay network configuration
# Define network information here
{...}: {
  flake.modules.nixos.umay = {lib, ...}: {
    # Networking uses simple DHCP
    networking.useDHCP = lib.mkDefault true;
  };
}

# VM network configuration for nixos guests
{...}: {
  flake.modules.nixos.virtual-machine = {lib, ...}: {
    # Networking uses simple DHCP
    networking.useDHCP = lib.mkDefault true;
  };
}

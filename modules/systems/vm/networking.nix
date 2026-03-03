# VM network configuration for nixos guests
{...}: {
  flake.modules.nixos = {
    vm = {lib, ...}: {
      # Networking uses simple DHCP
      networking.useDHCP = lib.mkDefault true;
    };
  };
}

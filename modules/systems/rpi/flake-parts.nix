# Raspberry Pi + nixos
{inputs, ...}: {
  flake-file = {
    inputs = {
      nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    };
  };
}

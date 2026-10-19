# Raspberry Pi + nixos
{...}: {
  flake-file = {
    inputs = {
      nixos-raspberrypi = {
        url = "github:nvmd/nixos-raspberrypi/main";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };
}

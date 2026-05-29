{inputs, ...}: {
  # Declarative disk partitioning for NixOS
  # https://github.com/nix-community/disko

  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    inputs.disko.flakeModules.default
  ];
}

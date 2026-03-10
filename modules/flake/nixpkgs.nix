{inputs, ...}: {
  flake = {
    flake-file.inputs = {
      # Package sources
      nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
      nur.url = "github:nix-community/NUR";

      # Auto-database fetching
      nix-index-database = {
        url = "github:nix-community/nix-index-database";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };
  };
}

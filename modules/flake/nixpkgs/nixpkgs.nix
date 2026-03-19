# Nixpkgs configuration
{inputs, ...}: let
  # Central variable for overlays we want to apply to invocations of pkgs in general
  myOverlays = [
    inputs.self.overlays.additions
    inputs.self.overlays.modifications
    inputs.self.overlays.unstable-packages
    inputs.nur.overlays.default
  ];
in {
  # Package sources
  flake-file.inputs = {
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

  # Unstable overlay to pkgs
  flake = {
    # Application of overlays in system setting
    # This module is auto-imported by factory functions
    modules.generic.nixpkgs = {...}: {
      config.nixpkgs = {
        config = {
          allowUnfree = true;
        };
        overlays = myOverlays;
      };
    };
  };

  # Global overrides to make the unstable and other outputs available
  # Use nixpkgs-darwin in darwin, and nixpkgs in other context
  perSystem = {system, ...}: let
    thisNixpkgs =
      if (builtins.match ".*-darwin" system) != null
      then inputs.nixpkgs-darwin
      else inputs.nixpkgs;
  in {
    _module.args.pkgs = import thisNixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = myOverlays;
    };
  };
}

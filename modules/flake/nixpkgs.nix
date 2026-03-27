# Nixpkgs configuration
{inputs, ...}: let
  # Overlays we want to apply to invocations of pkgs in general
  myOverlays = [
    inputs.self.overlays.additions
    inputs.self.overlays.modifications
    inputs.self.overlays.unstable-packages
    inputs.nur.overlays.default
  ];
  # Configuration to apply to nixpkgs
  nixpkgsConfig = {
    allowUnfree = true;
  };
in {
  config = {
    # Central config location for nixpkgs sources config
    flake-file.inputs = {
      # Flake inputs

      # Package sources
      nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
      nur = {
        url = "github:nix-community/NUR";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };

      # System utilities, here for easy version upgrades
      home-manager = {
        url = "github:nix-community/home-manager/release-25.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nix-darwin = {
        url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
        inputs.nixpkgs.follows = "nixpkgs-darwin";
      };

      # Auto-database fetching for nixpkgs
      nix-index-database = {
        url = "github:nix-community/nix-index-database";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    flake = {
      # Application of overlays in system setting
      # This module is auto-imported by factory functions
      modules.generic.nixpkgs = {...}: {
        config.nixpkgs = {
          config = nixpkgsConfig;
          overlays = myOverlays;
        };
      };

      # Unstable overlay to add unstable pkgs to pkgs.unstable
      overlays = {
        unstable-packages = final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = final.stdenv.hostPlatform.system;
            config = final.config;
          };
        };
      };
    };

    # Global setting for pkgs used by this flake
    perSystem = {system, ...}: let
      # Use nixpkgs-darwin in darwin, and nixpkgs in other context
      thisNixpkgs =
        if (builtins.match ".*-darwin" system) != null
        then inputs.nixpkgs-darwin
        else inputs.nixpkgs;
    in {
      _module.args.pkgs = import thisNixpkgs {
        inherit system;
        config = nixpkgsConfig;
        overlays = myOverlays;
      };
    };
  };
}

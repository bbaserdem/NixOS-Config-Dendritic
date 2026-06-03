# Nixpkgs configuration
{
  inputs,
  lib,
  config,
  ...
}: let
  version = config.localConfig.nixVersion;
in {
  # Define new options to use for all nixpkgs invocations
  options = {
    localConfig = {
      nixVersion = lib.mkOption {
        type = lib.types.str;
        description = "Nix tooling version";
      };
      nixpkgs = {
        overlays = lib.mkOption {
          type = lib.types.listOf lib.types.raw;
          default = [];
          description = "List of overlays to apply to nixpkgs invocations";
        };
        config = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          description = "Configuration to be applied to nixpkgs invocations";
        };
      };
    };
  };

  config = {
    # Set flake version
    localConfig.nixVersion = "26.05";

    # Central config location for nixpkgs sources config
    flake-file.inputs = {
      # Flake inputs

      # Package sources
      nixpkgs.url = "github:nixos/nixpkgs/nixos-${version}";
      nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-${version}-darwin";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      # Nix User Repository
      nur = {
        url = "github:nix-community/NUR";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
      # Chaotic Nyx : bleeding bleeding edge
      chaotic = {
        url = "github:chaotic-cx/nyx";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };

      # System utilities, here for easy version upgrades
      home-manager = {
        url = "github:nix-community/home-manager/release-${version}";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nix-darwin = {
        url = "github:nix-darwin/nix-darwin/nix-darwin-${version}";
        inputs.nixpkgs.follows = "nixpkgs-darwin";
      };
      stylix.url = "github:nix-community/stylix/release-${version}";

      # Auto-database fetching for nixpkgs
      nix-index-database = {
        url = "github:nix-community/nix-index-database";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    localConfig.nixpkgs = {
      config = {
        allowUnfree = true;
      };
      overlays = [
        inputs.self.overlays.additions
        inputs.self.overlays.modifications
        inputs.self.overlays.unstable-packages
        inputs.nur.overlays.default
      ];
    };

    flake = {
      # Application of overlays in system setting
      # This module is auto-imported by factory functions
      modules.generic.nixpkgs = {...}: {
        config = {
          inherit (config.localConfig) nixpkgs;
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
        inherit (config.localConfig.nixpkgs) config overlays;
      };
    };
  };
}

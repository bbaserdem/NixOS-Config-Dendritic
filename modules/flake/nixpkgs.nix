# Nixpkgs configuration
{
  inputs,
  config,
  ...
}: let
  version = config.nixpkgs.version;
in {
  config = {
    # Central config location for nixpkgs sources config
    flake-file.inputs = {
      # Flake inputs

      # Package sources
      nixpkgs.url = "https://channels.nixos.org/nixos-${version}/nixexprs.tar.zst";
      nixpkgs-darwin.url = "https://channels.nixos.org/nixpkgs-${version}-darwin/nixexprs.tar.zst";
      nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
      # Nix User Repository
      nur = {
        url = "github:nix-community/NUR";
        inputs = {
          flake-parts.follows = "flake-parts";
          nixpkgs.follows = "nixpkgs-unstable";
        };
      };
      # Chaotic Nyx : bleeding bleeding edge
      chaotic = {
        url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
        inputs = {
          nixpkgs.follows = "nixpkgs-unstable";
          home-manager.follows = "home-manager";
        };
      };

      # System utilities, here for easy version upgrades
      nix-darwin = {
        url = "github:nix-darwin/nix-darwin/nix-darwin-${version}";
        inputs.nixpkgs.follows = "nixpkgs-darwin";
      };
    };

    # Config options to globally set for nixpkgs
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
      # Add the NUR overlay to system overlays
      overlays = [
        inputs.nur.overlays.default # NUR overlay
      ];
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
        inherit (config.nixpkgs) config overlays;
      };
    };
  };
}

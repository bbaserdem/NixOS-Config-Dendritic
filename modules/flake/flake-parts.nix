# setup of tools for dendritic pattern
#
# Simplify Nix Flakes with the module system
# https://github.com/hercules-ci/flake-parts
#
# Generate flake.nix from module options.
# https://github.com/vic/flake-file
#
# Import all nix files in a directory tree.
# https://github.com/vic/import-tree
{
  inputs,
  lib,
  ...
}: {
  # New output options to our flake-parts repo
  options = {
    flake = {
      # Helper functions for creating system / home-manager configurations
      lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = {};
      };

      # Factory aspect functions
      factory = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = {};
      };
    };
  };

  # Load dendritic flake modules
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-parts.flakeModules.modules
  ];

  config = {
    # Flake-Parts sources
    flake-file.inputs = {
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      flake-file.url = "github:vic/flake-file";
      import-tree.url = "github:vic/import-tree";
    };

    # Systems we will be building for
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    # Library functions, migrate this
    flake.lib = {
      # Standalone home-manager config builder
      # Will not be used in this flake, but possible
      # Historically, passed host parameter to the configuration to auto-load host specific user config
      # This is not needed with flake-parts, but host-specific behavior requires home-manager as nixos/nix-darwin module
      mkHomeManager = {
        system,
        user,
        ...
      }: {
        ${user} = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          modules = [
            inputs.self.modules.homeManager.${user}
            {nixpkgs.config.allowUnfree = true;}
          ];
        };
      };
    };
  };
}

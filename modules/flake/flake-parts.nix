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
    # Factory aspect functions, that help with declaring options
    factory = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
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
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";
    };

    # Systems we will be building for
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}

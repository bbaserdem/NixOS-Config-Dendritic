# Flake-Parts setup
{
  inputs,
  lib,
  flake-parts-lib,
  ...
}: {
  # New output options to our flake-parts repo
  options = {
    # No native darwinModules output in flake-parts; so we define here
    flake = flake-parts-lib.mkSubmoduleOptions {
      darwinModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
      };
    };

    # Factory aspect functions, that help with declaring options
    factory = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
    };
  };

  # Load flake-parts modules
  imports = [
    (inputs.flake-parts.flakeModules.modules or {})
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.flake-file.flakeModules.auto-follow or {})
  ];

  config = {
    # Dendritic pattern sourcing
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
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}

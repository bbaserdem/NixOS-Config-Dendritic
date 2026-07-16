# Flake-Parts setup
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

  # Load flake-parts modules
  imports = [
    (inputs.flake-parts.flakeModules.modules or {})
    (inputs.flake-file.flakeModules.dendritic or {})
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

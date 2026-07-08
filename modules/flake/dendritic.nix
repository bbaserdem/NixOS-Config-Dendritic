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
  den,
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
    (inputs.den.flakeModules.default or {})
    # (den.flakeModules.strict or {}) Bugged, throws immediately
  ];

  config = {
    # Dendritic pattern sourcing
    flake-file.inputs = {
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      den.url = "github:denful/den/v0.18.0";
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";
    };

    # Replacement for inporting den.flakeModules.strict not working
    den.schema = {
      host = den.lib.strict;
      user = den.lib.strict;
      home = den.lib.strict;
    };

    # Systems we will be building for
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}

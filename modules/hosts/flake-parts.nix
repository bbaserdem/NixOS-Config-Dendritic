# Host related flake-parts configuration
{
  lib,
  flake-parts-lib,
  ...
}: {
  # Currently, there's no nix-darwin module for flake-parts,
  # Manually add flake.darwinConfigurations as flake output
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      darwinConfigurations = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
      };
    };
  };
}

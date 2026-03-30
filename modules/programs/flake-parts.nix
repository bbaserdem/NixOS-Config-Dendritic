# Flake parts uses it's own modules.<context> formation
# We want to export our modules to canonical flake output format
{
  inputs,
  flake-parts-lib,
  lib,
  ...
}: {
  # Add darwin modules as flake outputs
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      darwinModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
      };
    };
  };

  config = {
    # Put modules as canonical modules
    flake.nixosModules = inputs.self.modules.nixos;
    flake.homeModules = inputs.self.modules.homeManager;
    flake.darwinModules = inputs.self.modules.darwin;
  };
}

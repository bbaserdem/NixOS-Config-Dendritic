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
    flake = {
      # Put all modules in as canonical modules
      nixosModules = inputs.self.modules.nixos;
      homeModules = inputs.self.modules.homeManager;
      darwinModules = inputs.self.modules.darwin;

      # Boilerplate for initializing system modules from home-manager modules
      factory = {
        inclusionModules = name: {
          homeManager."${name}" = {...}: {
            # Just init this module as empty
          };
          # Generic home-manager shared module importer
          generic."${name}" = {...}: {
            home-manager.sharedModules = [
              inputs.self.modules.homeManager."${name}"
            ];
          };
          # Import generic module to system
          nixos."${name}" = {...}: {
            imports = [
              inputs.self.modules.generic."${name}"
            ];
          };
          darwin."${name}" = {...}: {
            imports = [
              inputs.self.modules.generic."${name}"
            ];
          };
        };
      };
    };
  };
}

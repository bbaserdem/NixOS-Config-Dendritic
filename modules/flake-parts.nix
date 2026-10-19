# Flake parts uses it's own modules.<context> formation
# We want to export our modules to canonical flake output format
{inputs, ...}: {
  flake = {
    nixosModules = inputs.self.modules.nixos;
    homeModules = inputs.self.modules.homeManager;
    darwinModules = inputs.self.modules.darwin;
  };
}

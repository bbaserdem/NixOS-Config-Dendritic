# Wrappers to encapsulate apps with their config
{inputs, ...}: {
  # https://github.com/BirdeeHub/nix-wrapper-modules

  flake-file.inputs = {
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  imports = [(inputs.wrappers.flakeModules.wrappers or {})];

  perSystem = {...}: {
    wrappers = {
      control_type = "exclude";
      packages = {
        # hello = true; # Disables the package hello from being built
      };
    };
  };
}

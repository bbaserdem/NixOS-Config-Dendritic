{inputs, ...}: {
  # Wrappers to encapsulate apps with their config
  # https://github.com/BirdeeHub/nix-wrapper-modules

  flake-file.inputs = {
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [inputs.wrappers.flakeModules.wrappers];

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    wrappers = {
      pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        inherit (pkgs) config;
      };
      control_type = "exclude";
      packages = {
        # hello = true; # Disables the package hello from being built
      };
    };
  };
}

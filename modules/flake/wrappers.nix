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
}

# Nix on droid from nix community
{
  inputs,
  config,
  ...
}: {
  # Load flake-parts modules
  imports = [
    (inputs.den.flakeModules.default or {})
    # (inputs.den.flakeModules.strict or {}) Bugged, throws immediately
  ];

  config = {
    # Den sourcing
    flake-file.inputs = {
      nix-on-droid = {
        url = "github:nix-community/nix-on-droid/master";
        inputs = {
          nixpkgs.follows = "nixpkgs";
          home-manager.follows = "home-manager";
        };
      };
    };
  };
}

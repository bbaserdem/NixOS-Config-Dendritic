# Nix on droid from nix community
{...}: {
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

  # TODO: Hook up the droid host kind to den
}

# Nix on droid from nix community
{inputs, ...}: {
  # Den sourcing
  flake-file.inputs = {
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/master";
    };
  };

  # TODO: Hook up the droid host kind to den
}

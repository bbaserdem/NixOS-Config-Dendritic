# Configuring Beets
{...}: {
  flake.modules.home-manager.beets = {pkgs, ...}: {
    # Beets package
    programs.beets.package = let
      # We will use unstable packages
      py = pkgs.unstable.python3.pkgs;

      # in nixpkgs, copyartifacts is in old version incompatible with current beets
      # version bump won't happen due to failing tests on the developer side
      # We just disable tests, and fetch the updated version
      # https://github.com/NixOS/nixpkgs/issues/476424
      # https://github.com/adammillerio/beets-copyartifacts/issues/15
      beets-copyartifacts-updated = py.beets-copyartifacts.overridePythonAttrs (old: rec {
        version = "0.1.6";
        src = pkgs.fetchFromGitHub {
          owner = "adammillerio";
          repo = "beets-copyartifacts";
          rev = "v${version}";
          hash = "sha256-fMnXuMwxylO9Q7EFPpkgwwNeBuviUa8HduRrqrqdMaI=";
        };
        meta = old.meta // {broken = false;};
        # Disable tests as they're incompatible with newer beets versions
        doCheck = false;
      });
    in
      (py.beets.override {
        pluginOverrides = {
          alternatives = {
            enable = true;
            propagatedBuildInputs = [py.beets-alternatives];
          };
          copyartifacts = {
            enable = true;
            propagatedBuildInputs = [beets-copyartifacts-updated];
          };
        };
      }).overrideAttrs (oldAttrs: {
        # Work around nixpkgs bug where plugin dependencies aren't properly included
        # Seems fixed, but test this again
        propagatedBuildInputs =
          oldAttrs.propagatedBuildInputs
          ++ [
            py.beets-alternatives
            beets-copyartifacts-updated
          ];
      });
  };
}

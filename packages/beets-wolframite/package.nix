{pkgs, ...}: let
  py = pkgs.unstable.python3.pkgs;
in
  py.beets.override {
    pluginOverrides = {
      alternatives = {
        enable = true;
        propagatedBuildInputs = [py.beets-alternatives];
      };
      filetote = {
        enable = true;
        propagatedBuildInputs = [py.beets-filetote];
      };
      wolframite = {
        enable = true;
        propagatedBuildInputs = [py.local.beets-wolframite];
      };
    };
  }

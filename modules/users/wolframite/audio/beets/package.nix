# Loading package with external plugins
{inputs, ...}: {
  flake.modules.homeManager.wolframite = {pkgs, ...}: {
    # Beets package; add external plugins
    programs.beets = {
      package = let
        py = pkgs.python3.pkgs;
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
              propagatedBuildInputs = [pkgs.local.beets-wolframite];
            };
          };
        };
      settings.plugins = [
        "wolframite"
      ];
    };
  };
}

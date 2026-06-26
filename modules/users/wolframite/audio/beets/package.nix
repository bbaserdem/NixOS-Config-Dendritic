# Loading package with external plugins
{...}: {
  flake.modules.homeManager.wolframite = {pkgs, ...}: {
    # Beets package; add external plugins
    # We use unstable, because filetote is broken on stable
    programs.beets = {
      package = pkgs.local.beets-wolframite;
      settings.plugins = [
        "wolframite"
      ];
    };
  };
}

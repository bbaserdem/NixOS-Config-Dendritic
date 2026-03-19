# Rewrite plugin config
# Allows for auto-changing tags
{...}: {
  flake.modules.home-manager.beets = {...}: {
    # This is basically the yaml array written in nix
    programs.beets = {
      settings = {
        plugins = [
          "advancedrewrite"
        ];
        # Plugin configs
        advancedrewrite = [
          {
            # Correct the many names of Osees
            match = "artist:\"Oh Sees\"";
            replacements = {
              albumartist = "Osees";
            };
          }
        ];
      };
    };
  };
}

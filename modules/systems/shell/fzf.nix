# Fuzzy finder
{...}: {
  flake.modules.homeManager = {
    # Enable stylix
    stylix = {...}: {
      stylix.targets.fzf.enable = true;
    };

    # Enable fzf
    shell = {...}: {
      programs.fzf = {
        enable = true;
      };
    };
  };
}

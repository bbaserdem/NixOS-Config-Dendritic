# Fuzzy finder
{...}: {
  # Enable fzf
  flake.modules.homeManager.shell-fzf = {...}: {
    programs.fzf = {
      enable = true;
    };
  };

  # TODO: DElete after den
  # Enable stylix
  flake.modules.homeManager.stylix = {...}: {
    stylix.targets.fzf.enable = true;
  };
}

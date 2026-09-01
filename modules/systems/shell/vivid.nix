# Shell colorizer
{...}: {
  flake.modules.homeManager.shell-vivid = {...}: {
    programs.vivid = {
      enable = true;
    };
  };

  # TODO: Delete after den migration
  flake.modules.homeManager.stylix = {...}: {
    stylix.targets.vivid = {
      enable = true;
      colors.enable = true;
    };
  };
}

# Obsidian config
{...}: {
  flake.modules.homeManager = {
    # Enable stylix theming
    stylix = {config, ...}: {
      stylix.targets.obsidian = {
        enable = true;
        colors.enable = true;
        fonts.enable = true;
        polarity.enable = true;
      };
    };

    # Enable obsidian
    obsidian = {...}: {
      programs.obsidian = {
        enable = true;
      };
    };
  };
}

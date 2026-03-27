# Mangohud; performance measurer
{...}: {
  flake.modules.homeManager = {
    # Enable stylix theming for mangohud
    stylix = {...}: {
      stylix.targets.mangohud.enable = true;
    };

    # Enable in home-manager
    mangohud = {...}: {
      programs.mangohud = {
        enable = true;
        enableSessionWide = false;
      };
    };
  };
}

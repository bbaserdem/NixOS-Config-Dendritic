# Zathura
{...}: {
  flake.modules.homeManager = {
    # Enable stylix theming
    stylix = {...}: {
      stylix.targets.zathura.enable = true;
    };

    # Enable zathura
    zathura = {...}: {
      programs.zathura = {
        enable = true;
        mappings = {
          "<C-i>" = "recolor";
        };
        options = {
          recolor-keephue = true;
          selection-keyboard = "clipboard";
          first-page-column = "1:1";
          incremental-search = false;
          statusbar-home-tilde = true;
          scroll-page-aware = true;
          scroll-step = 50;
        };
      };
    };
  };
}

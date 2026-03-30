# Btop; system monitor
{...}: {
  flake.modules.homeManager = {
    # Enable stylix theming
    stylix = {...}: {
      stylix.targets.btop.enable = true;
    };

    # Enable in home-manager
    btop = {...}: {
      programs.btop = {
        enable = true;
        settings = {
          proc_sorting = "cpu lazy";
        };
      };
    };
  };
}

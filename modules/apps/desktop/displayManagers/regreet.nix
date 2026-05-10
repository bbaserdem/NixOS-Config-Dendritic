# Regreet setup for nixos systems
{...}: {
  flake.modules = {
    nixos = {
      regreet = {...}: {
        local.displayManager = "regreet";
        # regreet doesn't have any setup other than an enable flag
      };

      # Stylix theming for configured display managers
      stylix = {...}: {
        stylix.targets.regreet = {
          enable = true;
          colors.enable = true;
          cursor.enable = true;
          fonts.enable = true;
          icons.enable = true;
          image.enable = true;
          imageScalingMode.enable = true;
        };
      };
    };
  };
}

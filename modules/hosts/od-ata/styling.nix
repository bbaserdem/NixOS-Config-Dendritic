# Od-Ata theming using stylix
{...}: {
  den = {
    # Entity record
    hosts.od-ata = {
      # Stylix is used
      stylix.enable = true;
      # Display manager of choice
      displayManager.name = "gdm";
      # Use gnome by default
      desktop.defaultSession = "gnome";
    };

    # Aspect for settings
    aspects.od-ata = {
      stylix = {pkgs, ...}: {
        # Pick the base16 scheme for this computer
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/darkviolet.yaml";
        # Default wallpaper for this computer
        image = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/odin-dark.jpg";

        # Fonts to be used
        fonts = with pkgs; {
          monospace = {
            package = undefined-medium;
            name = "undefined medium";
          };
          serif = {
            package = caladea;
            name = "Caladea";
          };
          sansSerif = {
            package = source-sans-pro;
            name = "Source Sans Pro";
          };
          emoji = {
            package = noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };

        # Icons to be used
        icons = {
          enable = true;
          package = pkgs.colloid-icon-theme;
          dark = "Colloid-Dark";
          light = "Colloid-Light";
        };

        cursor = {
          package = pkgs.afterglow-cursors-recolored;
          name = "Afterglow-Recolored-Dracula-Red";
          size = 24;
        };

        opacity = {
          applications = 1.0;
          desktop = 0.9;
          popups = 0.9;
          terminal = 0.9;
        };
      };
    };
  };
}

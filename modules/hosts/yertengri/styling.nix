# Yertengri theming choices
{...}: {
  den = {
    hosts.yertengri = {
      # Display manager of choice
      displayManager = {
        name = "sddm";
        config = {
          # For sddm's astronaut theme
          embeddedTheme = "black_hole";
          # For catppuccin
          flavor = "macchiato";
          accent = "teal";
          loginBackground = true;
          userIcon = true;
          clockEnabled = true;
        };
      };
    };

    aspects.yertengri = {
      # Stylix system settings for yertengri
      stylix = {pkgs, ...}: {
        # Pick the base16 scheme for this computer
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        # Default wallpaper for this computer
        image = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/Snow-Capped Mountain.jpg";

        # Fonts to be used
        fonts = with pkgs; {
          monospace = {
            package = _3270font;
            name = "IBM 3270";
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
          package = pkgs.qogir-icon-theme;
          dark = "Qogir-Dark";
          light = "Qogir";
        };

        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
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

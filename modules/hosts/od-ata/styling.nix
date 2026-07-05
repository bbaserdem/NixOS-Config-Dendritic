# Od-Ata theming using stylix
{...}: {
  flake.modules.nixos.od-ata = {
    pkgs,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      {
        local.displayManager = {
          name = "sddm";
          config = {
            # For sddm astronaut theme
            embeddedTheme = "cyberpunk";
            # For catppuccin
            flavor = "frappe";
            accent = "red";
            loginBackground = true;
            userIcon = true;
            clockEnabled = true;
          };
        };
      }
      (
        lib.optionalAttrs (lib.hasAttrByPath ["stylix"] options) {
          stylix = {
            # Pick the base16 scheme for this computer
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
        }
      )
    ];
  };
}

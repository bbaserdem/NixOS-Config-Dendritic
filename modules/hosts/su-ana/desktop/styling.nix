# Su-ana theming
{inputs, ...}: {
  flake.modules.darwin.su-ana = {pkgs, ...}: {
    stylix = {
      # Pick the base16 scheme for this user
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

      # Fonts to be used, not super relevant in darwin context
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

      opacity = {
        applications = 1.0;
        desktop = 0.9;
        popups = 0.9;
        terminal = 0.9;
      };
    };
  };
}

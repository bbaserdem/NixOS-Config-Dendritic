# Su-ana theming
{...}: {
  den = {
    hosts.su-ana = {
      # Enable stylix; but integration is limited in darwin
      stylix.enable = true;
    };

    aspects.su-ana = {
      stylix = {pkgs, ...}: {
        # Pick the base16 scheme for this user
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        # Default wallpaper for this computer. Pull this data asset from the Linux
        # package set because elementary-wallpapers is not marked as darwin
        image = "${pkgs.pkgsCross.aarch64-multiplatform.pantheon.elementary-wallpapers}/share/backgrounds/Photo by SpaceX.jpg";
        # image = "${inputs.nixpkgs.legacyPackages."aarch64-linux".pantheon.elementary-wallpapers}/share/backgrounds/Photo by SpaceX.jpg";

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
  };
}

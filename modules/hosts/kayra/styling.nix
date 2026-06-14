# Kayra theming using stylix
{inputs, ...}: {
  flake.modules.nixos.kayra = {
    pkgs,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      {
        local.displayManager.name = "gdm";
      }
      (
        lib.optionalAttrs (lib.hasAttrByPath ["stylix"] options) {
          stylix = {
            # Pick the base16 scheme for this computer
            base16Scheme = "${pkgs.base16-schemes}/share/themes/sandcastle.yaml";
            # Default wallpaper for this
            image = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds/A Trail of Footprints In The Sand.jpg";

            # Fonts to be used
            fonts = with pkgs; {
              monospace = {
                package = maple-mono.truetype;
                name = "Maple Mono";
              };
              serif = {
                package = eb-garamond;
                name = "EB Garamond";
              };
              sansSerif = {
                package = inter;
                name = "Inter";
              };
              emoji = {
                package = noto-fonts-color-emoji;
                name = "Noto Color Emoji";
              };
            };

            # Icons to be used
            icons = {
              enable = true;
              package = pkgs.papirus-icon-theme;
              dark = "Papirus-Dark";
              light = "Papirus-Light";
            };

            cursor = {
              package = pkgs.everforest-cursors;
              name = "everforest-cursors";
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

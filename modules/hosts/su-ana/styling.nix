# Su-ana theming
{inputs, ...}: let
  elementaryWallpapers = inputs.nixpkgs.legacyPackages."aarch64-linux".pantheon.elementary-wallpapers;
in {
  flake.modules.darwin.su-ana = {
    pkgs,
    options,
    lib,
    ...
  }: {
    config = lib.optionalAttrs (lib.hasAttrByPath ["stylix"] options) {
      stylix = {
        # Pick the base16 scheme for this user
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        # Default wallpaper for this computer. Pull this data asset from the Linux
        # package set because elementary-wallpapers is not marked for Darwin.
        image = "${elementaryWallpapers}/share/backgrounds/Photo by SpaceX.jpg";

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

# Configuring ghostty for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      (
        # Edit stylix settings if we can
        lib.optionalAttrs (lib.hasAttrByPath ["stylix"] options) {
          programs.ghostty.settings.theme = "dark:stylix,light:Selenized Light";
          stylix.targets.ghostty.fonts.override = lib.mkMerge [
            {
              monospace = {
                name = "Victor Mono";
                package = pkgs.victor-mono;
              };
            }
            (
              # Enlarge fonts on darwin
              lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
                sizes.terminal = 9.375;
              }
            )
          ];
        }
      )
      (
        # Edit stylix settings if can
        lib.optionalAttrs (!(lib.hasAttrByPath ["stylix"] options)) {
          programs.ghostty.settings.theme = "dark:Selenized Dark,light:Selenized Light";
        }
      )
      (
        # Edit stylix settings if can
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.ghostty.settings = {
            macos-icon = "microchip";
          };
        }
      )
      {
        programs.ghostty.settings = {
          # Font options
          font-style = "SemiBold";
          font-style-bold = "Bold";
          font-style-italic = "Light Oblique";
          font-style-bold-italic = "Bold Italic";
          font-feature = "+ss04, +ss06, +ss07";
        };
      }
    ];
  };
}

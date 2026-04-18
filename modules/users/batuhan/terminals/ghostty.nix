# Configuring ghostty for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    ...
  }: {
    # Override the font settings in stylix
    stylix.targets.ghostty.fonts.override = lib.mkMerge [
      {
        monospace = {
          name = "Victor Mono";
          package = pkgs.victor-mono;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          # Stylix inflates terminal font size in darwin
          sizes.terminal = 9;
        }
      )
    ];
    programs.ghostty = lib.mkMerge [
      {
        # Settings
        settings = {
          theme = "dark:stylix,light:Selenized Light";
          # Font options
          font-style = "Light";
          font-style-bold = "Bold";
          font-style-italic = "Light Oblique";
          font-style-bold-italic = "Bold Italic";
          font-feature = "+ss04, +ss06, +ss07";
        };
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
        # MacOS only settings
        settings = {
          macos-icon = "microchip";
        };
      })
    ];
  };
}

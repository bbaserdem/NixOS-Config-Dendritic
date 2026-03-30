# Office suite
{...}: {
  flake.modules.homeManager.office = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        home.packages = with pkgs; [
          (
            libreoffice-qt-fresh.override {
              withFonts = false; # Don't provide fonts, we will provide
              kdeIntegration = true; # Do KDE integration
            }
          )
        ];
      })
    ];
  };
}

# Office suite
{...}: {
  flake.modules.homeManager.office = {pkgs, ...}: {
    # Install packages to userspace
    home.packages = with pkgs; [
      ( # Office suite
        libreoffice-qt-fresh.override {
          withFonts = false; # Don't provide fonts, we will provide
          kdeIntegration = true; # Do KDE integration
        }
      )
      enchant2 # Spellchecker library that can use nuspell
      nuspell # Spellchecker hunspell alternative that can do agglutinative
    ];

    # Tell enchant to prefer nuspell
    xdg.configFile."enchant/enchant.ordering" = {
      enable = true;
      text = ''
        # Use nuspell for everything first, then fall back to hunspell
        *:nuspell,hunspell,aspell
      '';
    };
  };
}

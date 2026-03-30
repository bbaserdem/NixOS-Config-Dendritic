# Language related software
{...}: {
  flake.modules.homeManager.language = {pkgs, ...}: {
    # Install spellcheckers to userspace
    home.packages = with pkgs; [
      enchant # Spellchecker library that can use nuspell
      nuspell # Spellchecker hunspell alternative that can do agglutinative
    ];

    # Spellchecker; enchant should use nuspell backend
    xdg.configFile."enchant/enchant.ordering" = {
      enable = true;
      text = ''
        # Use nuspell for everything first, then fall back to hunspell
        *:nuspell,hunspell,aspell
      '';
    };
  };
}

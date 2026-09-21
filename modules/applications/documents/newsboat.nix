# Newsboat, CLI rss feed
{...}: {
  # Module
  flake.modules.homeManager.newsboat-settings = {...}: {
    key = "newsboat-settings#homeManager";
    config = {
      programs.newsboat = {
        enable = true;
        autoReload = true;
        maxItems = 0;
        reloadTime = 10;
        extraConfig = ''
          notify-always yes
          notify-format "%f unread feeds ($n unread in total)"
          notify-beep no
          confirm-exit no
          urls-source "local"
          datetime-format "%y/%m/%d"
          delete-played-files no
          max-downloads 3
        '';
      };
    };
  };
}

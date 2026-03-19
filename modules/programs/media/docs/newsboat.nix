# Configuring newsboat, CLI rss feed
{...}: {
  flake.modules.home-manager.newsboat = {
    config,
    pkgs,
    ...
  }: let
    downloadPath =
      if (pkgs.stdenv.hostPlatform.isLinux)
      then "${config.xdg.userDirs.download}"
      else "~/Downloads";
  in {
    programs.newsboat = {
      enable = true;
      autoReload = true;
      maxItems = 0;
      reloadTime = 10;
      extraConfig = ''
        notify-always yes
        notify-format "%f unread feeds ($n unread in total)"
        notify-program newsboat-notify.sh
        notify-beep no
        confirm-exit no
        urls-source "local"
        datetime-format "%d/%m/%y"
        delete-played-files no
        download-path "${downloadPath}/Podcast %n %h"
        max-downloads 3
        player "mpd"
      '';
    };
  };
}

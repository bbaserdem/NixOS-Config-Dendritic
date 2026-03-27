# Configuring user level newsboat settings
{...}: {
  flake.modules.homeManager.batuhan = {
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
      extraConfig = ''
        download-path "${downloadPath}/Podcast %n %h"
        player "mpd"
      '';
    };
  };
}

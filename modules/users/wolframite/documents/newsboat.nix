# Configuring user level newsboat settings
{...}: {
  flake.modules.homeManager.wolframite-newsboat = {config, ...}: {
    key = "wolframite-newsboat#homeManager";
    config = {
      programs.newsboat = {
        extraConfig = ''
          download-path "${config.xdg.userDirs.download or "~/Downloads"}/Podcast %n %h"
          player "mpd"
        '';
      };
    };
  };
}

# YT-DLP settings
{...}: {
  flake.modules.homeManager.wolframite-ytdlp = {config, ...}: {
    key = "wolframite-ytdlp#homeManager";
    config = {
      programs.yt-dlp.settings = {
        paths = "home:${config.xdg.userDirs.download or "~/Downloads"}/Yt-Dlp";
        output = "%(title)s/%(title)s-%(resolution)s";
        sub-langs = "en.*,tr.*,tur.*";
      };
    };
  };
}

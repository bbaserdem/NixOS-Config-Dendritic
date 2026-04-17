# User config for yt-dlp
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    config,
    ...
  }: let
    downloadDir =
      if pkgs.stdenv.hostPlatform.isLinux
      then "${config.xdg.userDirs.download}/Youtube-Dlp"
      else "~/Downloads/Youtube-Dlp";
  in {
    programs.yt-dlp = {
      settings = {
        # Filesystem options
        paths = "home:${downloadDir}";
        output = "%(title)s/%(title)s-%(resolution)s";
        # Subtitle options
        sub-langs = "en.*,tr.*,tur.*";
      };
    };
  };
}

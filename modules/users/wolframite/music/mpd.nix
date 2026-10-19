# MPD settings
{flib, ...}: {
  flake.modules.homeManager.wolframite-mpd = {
    config,
    lib,
    pkgs,
    ...
  }: {
    key = "wolframite-mpd#homeManager";
    config = lib.mkMerge [
      {
        services.mpd = {
          musicDirectory = config.xdg.userDirs.music or "~/Music";
          playlistDirectory = config.xdg.userDirs.music or "~/Music";
        };
        home.file.mpd-ignore = {
          target =
            (
              flib.stripRootDir
              config.home.homeDirectory
              config.services.mpd.musicDirectory
            )
            + "/.mpdignore";
          text = ''
            Staging
            Sort
            Unsorted
            Lossy
            ${ # Lossy subset be available in darwin
              if pkgs.stdenv.hostPlatform.isLinux
              then "Mobile"
              else ""
            }
          '';
        };
      }
    ];
  };
}

# Filetype conversion plugins
# Allows for auto-changing tags
{...}: {
  flake.modules.homeManager.wolframite = {config, ...}: let
    musicDir = config.services.mpd.musicDirectory;
    playlistDir = config.services.mpd.playlistDirectory;
  in {
    # This is basically the yaml array written in nix
    programs.beets.settings = {
      plugins = [
        "playlist"
        "importfeeds"
        "smartplaylist"
      ];

      # Auto adjust playlists with beets library management
      playlist = {
        auto = true;
        playlist_dir = playlistDir;
        relative_to = musicDir;
      };

      # Keep a playlist of recently added files
      importfeeds = {
        formats = "m3u";
        m3u_name = "Recents.m3u";
        dir = playlistDir;
        relative_to = musicDir;
      };

      # Generate dynamic playlists
      smartplaylist = {
        auto = true;
        playlist_dir = playlistDir;
        relative_to = musicDir;
        playlists = [
          {
            name = "JoeyFavs.m3u";
            query = "introducer:Joseph Hirsh";
          }
          {
            name = "Mood-Instrumental.m3u";
            query = "mood:instrumental";
          }
          {
            name = "Mood-Microtonal.m3u";
            query = "mood:microtonal";
          }
          {
            name = "Mood-Affirmation.m3u";
            query = "mood:affirmation";
          }
          {
            name = "Mood-Heavy.m3u";
            query = "mood:heavy";
          }
          {
            name = "Mood-Turkish.m3u";
            query = "mood:turkish";
          }
          {
            name = "Mood-Japanese.m3u";
            query = "mood:japanese";
          }
          {
            name = "Mood-Ambient.m3u";
            query = "mood:ambient";
          }
          {
            name = "Mood-Electronic.m3u";
            query = "mood:electronic";
          }
          {
            name = "Mood-Space.m3u";
            query = "mood:space";
          }
          {
            name = "Mood-Phonk.m3u";
            query = "mood:phonk";
          }
          {
            name = "Mood-Trippy.m3u";
            query = "mood:trippy";
          }
          {
            name = "Mood-Gag.m3u";
            query = "mood:gag";
          }
        ];
      };
    };
  };
}

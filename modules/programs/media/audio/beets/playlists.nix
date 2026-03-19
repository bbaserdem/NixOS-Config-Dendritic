# Filetype conversion plugins
# Allows for auto-changing tags
{...}: {
  flake.modules.home-manager.beets = {config, ...}: let
    musicDir = config.services.mpd.musicDirectory;
    playlistDir = config.services.mpd.playlistDirectory;
  in {
    # This is basically the yaml array written in nix
    programs.beets = {
      settings = {
        plugins = [
          "importfeeds"
          "playlist"
          "smartplaylist"
        ];
        types = {
          game = "bool";
        };
        importfeeds = {
          formats = "m3u_session";
          dir = playlistDir;
          relative_to = musicDir;
          m3u_name = "Import-";
        };
        playlist = {
          auto = true;
          playlist_dir = playlistDir;
          relative_to = musicDir;
        };
        smartplaylist = {
          auto = true;
          playlist_dir = playlistDir;
          relative_to = musicDir;
          playlists = [
            {
              name = "JoeyFavs.m3u";
              album_query = "introducer:Joseph Hirsh";
              query = "introducer:Joseph Hirsh";
            }
            {
              name = "Mood-Instrumental.m3u";
              album_query = "mood:instrumental";
            }
            {
              name = "Mood-Microtonal.m3u";
              album_query = "mood:microtonal";
            }
            {
              name = "Mood-Affirmation.m3u";
              album_query = "mood:affirmation";
            }
            {
              name = "Mood-Heavy.m3u";
              album_query = "mood:heavy";
            }
            {
              name = "Mood-Turkish.m3u";
              album_query = "mood:turkish";
            }
            {
              name = "Mood-Japanese.m3u";
              album_query = "mood:japanese";
            }
            {
              name = "Mood-Ambient.m3u";
              album_query = "mood:ambient";
            }
            {
              name = "Mood-Electronic.m3u";
              album_query = "mood:electronic";
            }
            {
              name = "Mood-Space.m3u";
              album_query = "mood:space";
            }
            {
              name = "Mood-Phonk.m3u";
              album_query = "mood:phonk";
            }
            {
              name = "Mood-Trippy.m3u";
              album_query = "mood:trippy";
            }
            {
              name = "Mood-Gag.m3u";
              album_query = "mood:gag";
            }
          ];
        };
      };
    };
  };
}

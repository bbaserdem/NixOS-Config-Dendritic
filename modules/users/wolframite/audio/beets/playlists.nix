# Playlist management
{flib, ...}: {
  flake.modules.homeManager.beets-wolframite = {config, ...}: let
    musicDir = config.services.mpd.musicDirectory;
    playlistDir = config.services.mpd.playlistDirectory;
    moods = [
      "instrumental"
      "microtonal"
      "affirmation"
      "heavy"
      "turkish"
      "japanese"
      "ambient"
      "electronic"
      "space"
      "phonk"
      "trippy"
      "gag"
      "cunt"
    ];
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
        formats = [
          "m3u"
          "m3u_session"
        ];
        m3u_name = "Import.m3u";
        dir = playlistDir;
        relative_to = musicDir;
      };

      # Generate dynamic playlists
      smartplaylist = {
        auto = true;
        playlist_dir = playlistDir;
        relative_to = musicDir;
        playlists =
          [
            # Joey songs in the library
            {
              name = "JoeyFavs.m3u";
              query = "introducer:\"Joseph Hirsh\"";
            }
          ]
          ++ (
            # Mood generated playlists
            moods
            |> builtins.map (
              p: {
                name = "Mood-${flib.capitalize p}.m3u";
                query = "mood:${p}";
              }
            )
          );
      };
    };
  };
}

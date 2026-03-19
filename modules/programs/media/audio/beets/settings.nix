# Config for Beets
{...}: {
  flake.modules.home-manager.beets = {config, ...}: let
    # Used variables for main config
    musicDir = config.services.mpd.musicDirectory;
    dbFile = "Beets_Library.db";
    logFile = "${config.xdg.cacheHome}/beets/log";
  in {
    # This is basically the yaml array written in nix
    # Beets behavior settings
    programs.beets = {
      enable = true;
      # Enable mpd integration
      mpdIntegration = {
        enableStats = true;
        enableUpdate = true;
      };
      settings = {
        directory = musicDir;
        library = "${musicDir}/${dbFile}";
        ignore_hidden = false;
        asciify_paths = false;
        path_sep_replace = "⌿";
        replace = {
          "^-" = "_"; # Replace leading dash
          "^/" = ""; # Remove leading directory creator
          "^\\." = ""; # Remove leading dots
          "^\\s+" = ""; # remove trailing white-space
          "\\s+\$" = ""; # remove ending white-space
          "[\\x00-\\x1f]" = ""; # Remove control characters
          "<" = "＜"; # Windows/Android restricted characters
          ">" = "＞";
          ":" = "∶";
          "\"" = "″";
          "\\?" = "⁇";
          "\\*" = "✱";
          "\\|" = "￨";
          "\\\\" = "⍀";
          "\\.\\.\\." = "…"; # Other replacements
          "&" = "＆";
        };
        threaded = true;
        sort_item = [
          "albumartist+"
          "artist+"
          "album+"
          "disc+"
          "track+"
        ];
        sort_case_insensitive = false;
        artist_credit = true;
        per_disc_numbering = true;
        # UI options
        ui = {
          color = true;
        };
        # Importer options
        import = {
          write = true;
          move = true;
          resume = "ask";
          from_scratch = false;
          quiet = false;
          quiet_fallback = "asis";
          log = logFile;
          default_action = "skip";
          languages = [
            "en"
            "tr"
            "jp"
          ];
          detail = false;
          duplicate_action = "ask";
          bell = true;
        };
        # Autotagger matching
        match = {
          strong_rec_thresh = 0.04;
        };
        # Path specifications
        paths = {
          default = "\${initial}/%tdot{%the{\${albumartist}}}/%if{\${division},\${division}/}%if{$date,[\${date}] }%tdot{\${album}%aunique{albumartist album,albumdisambig}}/%if{\${tracknumber},\${tracknumber}. }\${title} - \${artist}";
          comp = "\${initial}/%tdot{%the{\${albumartist}}}/%if{\${division},\${division}/}%if{$date,[\${date}] }%tdot{\${album}%aunique{albumartist album,albumdisambig}}/%if{\${tracknumber},\${tracknumber}. }\${title} - \${artist}";
          singleton = "[\${initial}]/%tdot{%the{\${albumartist}}}/%if{$date,[\${date}] }\${title} - \${artist}";
        };
        # Plugins
        plugins = [
          # Metadata sources
          "discogs"
          "deezer"
          #"beatport"
          #"spotify"
          # Builtin plugins
          "albumtypes"
          "autobpm"
          "badfiles"
          "duplicates"
          "info"
          "missing"
          "edit"
          "fetchart"
          "embedart"
          "importadded"
          "lastgenre"
          "lyrics"
          "replaygain"
          "the"
          "thumbnails"
          "types"
          "zero"
          # External plugins
          "alternatives"
          "copyartifacts"
        ];
        autobpm = {
          auto = false;
          overwrite = false;
        };
        badfiles = {
          check_on_import = true;
          commands = {
            flac = "flac --test --warnings-as-errors --silent";
          };
        };
        embedart = {
          auto = true;
          ifempty = false;
          maxwidth = 256;
          remove_art_file = false;
        };
        fetchart = {
          auto = true;
          sources = [
            "filesystem"
            "coverart: release"
            "itunes"
            "coverart: releasegroup"
            "albumart"
            "amazon"
            "wikipedia"
            "*"
          ];
          high_resolution = true;
          store_source = true;
        };
        lastgenre = {
          auto = true;
          force = false;
          keep_existing = true;
          source = "album";
        };
        lyrics = {
          auto = true;
          force = false;
          sources = [
            "lrclib"
            "genius"
          ];
          synced = true;
        };
        mpd = {
          rating = true;
          host = config.services.mpd.network.listenAddress;
          port = config.services.mpd.network.port;
        };
        replaygain = {
          auto = true;
          backend = "ffmpeg";
          overwrite = false;
        };
        thumbnails = {
          auto = true;
          force = false;
        };
        types = {
          dap = "bool";
        };
        zero = {
          auto = true;
          comments = [
            "EAC"
            "LAME"
            "from.+collection"
            "ripped by"
          ];
          fields = "comments";
          update_database = true;
        };
        # External plugins
        copyartifacts = {
          extensions = ".*";
          print_ignored = "yes";
        };
      };
    };
  };
}

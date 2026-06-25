# Metadata plugins and workflows
{...}: {
  flake.modules.homeManager.wolframite = {...}: {
    programs.beets.settings = {
      plugins = [
        "autobpm"
        "edit"
        "importadded"
        "lastgenre"
        "lyrics"
        "replaygain"
        "zero"
      ];

      # Auto-tagger settings
      artist_credit = true;
      match = {
        strong_rec_thresh = 0.04;
      };

      # Calculate bpm of tracks (using librosa)
      # Takes a long time, so manually invoke this
      autobpm = {
        auto = false;
        force = false;
      };

      # Allow editing tags from text editor
      edit = {
        itemfields = [
          "track"
          "title"
          "artist"
          "album"
          "mood"
          "collection"
          "lossy"
          "introducer"
        ];
        albumfields = [
          "album"
          "albumartist"
          "artist"
          "genres"
          "mood"
          "collection"
          "lossy"
          "introducer"
        ];
      };

      # Sync file mtime with the database
      importadded = {
        preserve_mtimes = false;
        preserve_write_mtimes = false;
      };

      # Import last.fm genres; on import time too
      lastgenre = {
        auto = true;
        canonical = true;
        count = 3;
        force = true;
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

      # Replaygain
      replaygain = {
        auto = true;
        backend = "ffmpeg";
        peak = true;
        overwrite = false;
      };

      # Null useles fields
      zero = {
        auto = true;
        fields = "comments";
        update_database = true;
        comments = [
          "EAC"
          "LAME"
          "from.+collection"
          "ripped by"
        ];
      };

      # Normalize tags; using self plugin
      wolframite = {
        field_translations = [
          {
            # Correct the many names of Osees
            match = "artist:\"Oh Sees\"";
            replacements = {
              albumartist = "Osees";
            };
          }
        ];
      };
    };
  };
}

# Dealing with assets
{...}: {
  flake.modules.homeManager.wolframite = {...}: {
    programs.beets.settings = {
      plugins = [
        "fetchart"
        "embedart"
        "filetote"
        "thumbnails"
      ];

      # Get album art
      fetchart = {
        auto = true;
        cautious = true;
        sources = [
          "filesystem"
          "coverart: release"
          "itunes"
          "coverart: releasegroup"
          "albumart"
          "amazon"
          "*"
        ];
        high_resolution = true;
        store_source = true;
      };

      # Embed album art into each track too
      embedart = {
        auto = true;
        ifempty = true;
        maxwidth = 256;
        remove_art_file = false;
        clearart_on_import = false;
      };

      # Auto-generate thumbnails
      thumbnails = {
        auto = true;
        force = false;
      };

      # Non-album art file movement
      filetote = {
        # Behavior
        print_ignored = true;
        duplicate_action = "merge";
        # Grab everything by default
        extensions = ".*";
        # Enable track-file pairing
        pairing.enabled = true;
        # Don't interfere with cover images
        exclude = {
          filenames = [
            "cover.jpg"
            "cover.png"
            ".DS_Store"
            "Thumbs.db"
            ".directory"
          ];
        };
      };
    };
  };
}

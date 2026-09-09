# Dealing with extra assets
{...}: {
  flake.modules.homeManager.beets-wolframite = {lib, ...}: let
    imageExtensions = [
      "jpg"
      "jpeg"
      "png"
      "webp"
      "gif"
      "bmp"
      "tif"
      "tiff"
      "avif"
    ];
    documentExtensions = [
      "nfo"
      "pdf"
      "txt"
    ];
  in {
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
          {coverart = "release";}
          "itunes"
          {coverart = "releasegroup";}
          "albumart"
          "amazon"
          "*"
        ];
        high_resolution = true;
        store_source = true;
        cover_names = ["cover"];
      };

      # Embed album art into each track too
      embedart = {
        auto = true;
        ifempty = false;
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
        # Collect all recognized media
        extensions = builtins.concatMap (builtins.map (e: ".${e}")) [
          # Document files
          documentExtensions
          # Image files
          imageExtensions
        ];
        paths =
          {
            # Unpaired non-artwork files
            "filetote:default" = "$albumpath/Extra/$old_filename";
            # Track-matched sidecards
            "filetote-pairing:default" = "$albumpath/$medianame_new";
          }
          // (
            # Album artwork should remain in the main album directory
            imageExtensions
            |> builtins.map (
              e:
                lib.nameValuePair
                "ext:.${e}"
                "$albumpath/$old_filename"
            )
            |> builtins.listToAttrs
          );
        patterns = {
          artwork = [
            "[Aa]rtwork/"
            "[Bb]ooklet/"
            "[Ss]cans/"
          ];
        };
        # Enable track-file pairing
        pairing = {
          enabled = true;
          pairing_only = false;
          extensions = [
            ".*"
          ];
        };
        exclude = {
          filenames =
            # Generic OS shit
            [
              ".DS_Store"
              "Thumbs.db"
              ".directory"
            ]
            # Don't interfere with fetchart
            ++ (builtins.map (e: "cover.${e}") imageExtensions);
          # Explicitly rule out non-useful data
          extensions = [
            ".m3u"
            ".m3u8"
            ".db"
          ];
        };
      };
    };
  };
}

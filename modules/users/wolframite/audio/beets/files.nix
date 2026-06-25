# Library file layout and moving settings
{...}: {
  flake.modules.homeManager.wolframite = {
    config,
    lib,
    ...
  }: {
    # This is basically the yaml array written in nix
    # Beets behavior settings
    programs.beets.settings = {
      # Main options
      directory = config.services.mpd.musicDirectory;
      plugins = [
        "albumtypes"
        "the"
      ];

      # Certain field behavior
      per_disc_numbering = true;

      # Naming
      paths = let
        # Main division folder to be used
        prefix = [
          # Collection name
          "%if{\${collection},\${collection},Main}"
          "/"
          # Organize by artist initial; defined in user plugin
          "\${artistinitial}"
          "/"
          # Use album artists, remove trailing dot (from user plugin)
          "%tdot{%the{\${albumartist}}}"
          "/"
        ];
        # Main track naming for album tracks
        albumFile = [
          # Create division subdirectory, (user plugin preferred over albumtypes)
          "%if{\${albumdivision},\${albumdivision}/}"
          # Album subdirectory
          "%if{\${albumdate},[\${albumdate}] }"
          "%tdot{\${album}%aunique{albumartist album,albumdisambig}}"
          "/"
          # File naming; dynamic track number provided by user plugin
          "%if{\${tracknumber},\${tracknumber}. }"
          "\${title}"
          " - "
          "\${artist}"
        ];
        # Single track files
        trackFile = [
          "%if{\${trackdate},[\${trackdate}] }"
          "\${title} - \${artist}"
        ];
      in {
        # Default file naming
        default = lib.strings.concatStrings (prefix ++ albumFile);
        comp = lib.strings.concatStrings (prefix ++ albumFile);
        singleton = lib.strings.concatStrings (prefix ++ trackFile);
      };

      # Filename sanitization settings
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
    };
  };
}

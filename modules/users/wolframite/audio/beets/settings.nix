# Main config entry for wolframite's beets config
{...}: {
  flake.modules.homeManager.beets-wolframite = {config, ...}: {
    programs.beets.settings = {
      # Plugins
      plugins = [
        "duplicates"
        "info"
        "missing"
        "fuzzy"
      ];

      # Main behavior
      sort_case_insensitive = false;
      sort_item = [
        "albumartist+"
        "artist+"
        "album+"
        "disc+"
        "track+"
      ];

      # UI options
      ui = {
        color = true;
      };

      # Importer options
      ignore_hidden = true;
      ignore = [
        ".*"
        "*~"
        "System Volume Information"
        "lost+found"
        "Staging"
        "Sort"
        "Unsorted"
      ];
      threaded = true;
      import = {
        write = true;
        move = true;
        resume = "ask";
        from_scratch = false;
        quiet = false;
        quiet_fallback = "asis";
        log = "${config.xdg.cacheHome}/beets/log";
        default_action = "skip";
        languages = ["en" "tr" "ja"];
        detail = false;
        duplicate_action = "ask";
        bell = true;
      };

      # Tools
      missing = {
        count = true;
        total = false;
      };
      duplicates = {
        delete = false;
        full = false;
      };
      fuzzy = {
        threshold = 0.9;
      };
    };
  };
}

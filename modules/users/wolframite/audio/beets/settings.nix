# Main config for Beets
{...}: {
  flake.modules.homeManager.wolframite = {config, ...}: let
  in {
    programs.beets.settings = {
      # Plugins
      plugins = [
        "duplicates"
        "info"
        "missing"
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
      ignore_hidden = false;
      ignore = [
        ".*"
        "*~"
        "System Volume Information"
        "lost+found"
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
        languages = ["en" "tr" "jp"];
        detail = false;
        duplicate_action = "ask";
        bell = true;
      };

      # Tools
      missing = {
        count = true;
        total = true;
      };
      duplicates = {
        delete = false;
        full = false;
      };
    };
  };
}

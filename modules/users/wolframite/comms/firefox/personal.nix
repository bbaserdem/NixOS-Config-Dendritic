# Configuring firefox preferences for profile: personal
{...}: {
  localConfig.users.wolframite.firefox.profiles.personal = {
    # Customize containers
    containers = {
      shopping = {
        name = "Shopping";
        id = 1;
        icon = "cart";
        color = "purple";
      };

      banking = {
        name = "Finance";
        id = 2;
        icon = "dollar";
        color = "green";
      };

      explicit = {
        name = "Porn";
        id = 3;
        icon = "pet";
        color = "red";
      };

      work = {
        name = "Work";
        id = 4;
        icon = "briefcase";
        color = "yellow";
      };
    };

    # Function to generate extensions
    extensions.packages = {pkgs, ...}:
      with pkgs.nur.repos.rycee.firefox-addons; [
        # Steam
        augmented-steam
        protondb-for-steam
        steam-database
        # Github
        catppuccin-web-file-icons
        enhanced-github
        # Bandcamp
        batchcamp
        # Twitch
        betterttv
        twitch-auto-points
        twitch_5
        # QoL
        h264ify
        private-grammar-checker-harper
        sponsorblock
        video-downloadhelper
        zotero-connector
      ];

    # Custom search engines
    search.engines = {
      "Dotapedia" = {
        urls = [{template = "https://liquipedia.net/dota2/index.php?search={searchTerms}";}];
        icon = "https://www.dota2.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000;
        definedAliases = ["@d2"];
      };
    };
  };
}

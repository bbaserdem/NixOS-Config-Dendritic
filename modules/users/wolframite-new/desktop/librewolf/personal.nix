# Configuring librewolf preferences for profile: personal
{den, ...}: {
  # Den machinery to dispatch start pages
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.librewolf-personal
      ];
      provides.librewolf-personal = {
        host,
        user,
      }: {
        name = "wolframite/librewolf-personal(${user.userName}@${host.name})";
        homeManager = {
          lib,
          options,
          ...
        }: {
          config = lib.optionalAttrs ((options.local or {}) ? librewolf) {
            local.librewolf.profiles.personal.settings = let
              pages =
                []
                ++ (
                  lib.optional
                  (host.networking.local.enable && user.syncthing.enable)
                  "http://syncthing.localhost/${user.userName}"
                )
                ++ (
                  lib.optional
                  (host.networking.local.enable && host.networking.local.docs)
                  "http://system-docs.localhost"
                );
            in (lib.mkIf (pages != []) {
              "browser.startup.page" = 1;
              "browser.startup.homepage" = lib.concatStringsSep "|" pages;
            });
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.wolframite-librewolf = {
    lib,
    options,
    pkgs,
    ...
  }: {
    config =
      lib.optionalAttrs
      ((options.local or {}) ? librewolf)
      {
        local.librewolf.profiles.personal = {
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
          };

          # Function to generate extensions
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
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
      };
  };
}

# Configuring firefox preferences for profile: personal
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
    programs.firefox.profiles.personal = {
      # Profile specific settings

      # Containers
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

      # Extensions
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
        # Casting
        castkodi
        # Quality of Life
        h264ify
        private-grammar-checker-harper
        sponsorblock
        # Downloaders
        video-downloadhelper
        # Zotero
        zotero-connector
      ];

      # Search engines
      search.engines = {
        # Builtin engines
        amazondotcom-us.metaData = {
          alias = "@a";
          hidden = false;
        };
        bing.metaData = {
          alias = "@b";
          hidden = true;
        };
        ddg.metaData = {
          alias = "@d";
          hidden = false;
        };
        wikipedia.metaData = {
          alias = "@w";
          hidden = false;
        };
        ebay.metaData = {
          alias = "@eb";
          hidden = true;
        };
        ecosia.metaData = {
          alias = "@ec";
          hidden = false;
        };
        qwant.metaData = {
          alias = "@qw";
          hidden = false;
        };
        reddit.metaData = {
          alias = "@r";
          hidden = false;
        };
        youtube.metaData = {
          alias = "@y";
          hidden = false;
        };

        # Nixpkgs search
        "Nix Packages ${pkgs.lib.trivial.codeName}" = {
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "channel";
                  value = pkgs.lib.trivial.release;
                }
                {
                  name = "sort";
                  value = "relevance";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@np"];
        };

        # NixOS options search
        "NixOS Options ${pkgs.lib.trivial.codeName}" = {
          urls = [
            {
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "channel";
                  value = pkgs.lib.trivial.release;
                }
                {
                  name = "sort";
                  value = "relevance";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@no"];
        };

        # Home-Manager options
        "Home Manager Options (${pkgs.lib.trivial.codeName})" = {
          urls = [
            {
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "source";
                  value = "home_manager";
                }
                {
                  name = "channel";
                  value = pkgs.lib.trivial.release;
                }
                {
                  name = "sort";
                  value = "relevance";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["@hm"];
        };

        # NixOS wiki
        "NixOS Wiki" = {
          urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
          icon = "https://nixos.wiki/favicon.png";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@nw"];
        };

        # Arch wiki
        "Arch Wiki" = {
          urls = [{template = "https://wiki.archlinux.org/index.php?search={searchTerms}";}];
          icon = "https://wiki.archlinux.org/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@aw"];
        };

        # Gentoo wiki
        "Gentoo Wiki" = {
          urls = [{template = "https://wiki.gentoo.org/?search={searchTerms}";}];
          icon = "https://wiki.gentoo.org/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@ge"];
        };

        # Dotapedia
        "Dotapedia" = {
          urls = [{template = "https://liquipedia.net/dota2/index.php?search={searchTerms}";}];
          icon = "https://www.dota2.com/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@d2"];
        };
      };
    };
  };
}

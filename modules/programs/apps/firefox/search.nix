# Configuring firefox search engines
{...}: {
  flake.modules.home-manager.firefox = {pkgs, ...}: {
    programs.firefox.profiles.default.search = {
      # Default settings
      default = "google";
      privateDefault = "google";
      force = true;

      # Search engine list
      engines = {
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
          definedAliases = ["@no"];
        };

        # NixOS wiki
        "NixOS Wiki" = {
          urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
          iconUpdateUrl = "https://nixos.wiki/favicon.png";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@nw"];
        };

        # Home-Manager options
        "Home Manager Options" = {
          urls = [
            {
              template = "https://home-manager-options.extranix.com/";
              params = [
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

        # Arch wiki
        "Arch Wiki" = {
          urls = [{template = "https://wiki.archlinux.org/index.php?search={searchTerms}";}];
          iconUpdateUrl = "https://wiki.archlinux.org/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@aw"];
        };

        # Gentoo wiki
        "Gentoo Wiki" = {
          urls = [{template = "https://wiki.gentoo.org/?search={searchTerms}";}];
          iconUpdateUrl = "https://wiki.gentoo.org/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@ge"];
        };

        # Wikipedia
        "Wikipedia" = {
          urls = [
            {
              template = "https://en.wikipedia.org/w/index.php";
              params = [
                {
                  name = "search";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          iconUpdateUrl = "https://en.wikipedia.org/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@wi"];
        };

        # Dotapedia
        "Dotapedia" = {
          urls = [{template = "https://liquipedia.net/dota2/index.php?search={searchTerms}";}];
          iconUpdateUrl = "https://www.dota2.com/favicon.ico";
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["@d2"];
        };

        # Google search
        "google".metaData.alias = "@g";
      };
    };
  };
}

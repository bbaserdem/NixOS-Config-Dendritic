# Configuring firefox search engines
{config, ...}: let
  inherit (config.localConfig) nixVersion;
in {
  flake.modules.homeManager.firefox-wolframite = {
    lib,
    options,
    ...
  }: {
    config = lib.optionalAttrs ((options.local or {}) ? firefox) {
      local.firefox.global.search = {
        # Default to duck duck go, google is very AI now
        default = "ddg";
        privateDefault = "ddg";
        force = true;

        # Search providers
        engines = {
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

          # Other search engines
          "Nix Packages ${nixVersion}" = {
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
                    value = nixVersion;
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
            icon = "https://nixos.org/favicon.png";
            definedAliases = ["@np"];
          };

          "NixOS Options ${nixVersion}" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = nixVersion;
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
            icon = "https://nixos.org/favicon.png";
            definedAliases = ["@no"];
          };

          "Home Manager Options ${nixVersion}" = {
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
                    value = nixVersion;
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
            icon = "https://nixos.org/favicon.png";
            definedAliases = ["@hm"];
          };

          "NixOS Wiki" = {
            urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
            icon = "https://wiki.nixos.org/nixos.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = ["@nw"];
          };

          "Arch Wiki" = {
            urls = [{template = "https://wiki.archlinux.org/index.php?search={searchTerms}";}];
            icon = "https://wiki.archlinux.org/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = ["@aw"];
          };

          "Gentoo Wiki" = {
            urls = [{template = "https://wiki.gentoo.org/?search={searchTerms}";}];
            icon = "https://wiki.gentoo.org/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = ["@ge"];
          };
        };
      };
    };
  };
}

# Configuring librewolf search engines
{config, ...}: {
  flake.modules.homeManager.wolframite-librewolf = {
    lib,
    options,
    ...
  }: {
    config = lib.optionalAttrs ((options.local or {}) ? librewolf) {
      local.librewolf.global.search = {
        # Default to duck duck go, google is very AI now
        default = "qwant";
        privateDefault = "google-web";
        force = true;

        order = [
          "qwant"
          "ddg"
          "wikipedia"
          "perplexity"
          "google-web"
        ];

        # Search providers
        engines = {
          # Qwant
          qwant.metaData = {
            alias = "@q";
            hidden = false;
          };
          # Duck-duck-go
          ddg.metaData = {
            alias = "@d";
            hidden = false;
          };
          # Hide firefox internal google engine
          google.metaData.hidden = true;
          google-web = {
            name = "Google Web";
            definedAliases = ["@g"];
            urls = [
              {
                template = "https://www.google.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                  {
                    name = "udm";
                    value = "14";
                  }
                ];
              }
            ];
          };
          # Wikipedia
          wikipedia.metaData = {
            alias = "@w";
            hidden = false;
          };
          # Other search engines
          "Nix Packages ${config.nixpkgs.version}" = {
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
                    value = config.nixpkgs.version;
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
          "NixOS Options ${config.nixpkgs.version}" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = config.nixpkgs.version;
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
          "Nix-Darwin Options ${config.nixpkgs.version}" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "source";
                    value = "darwin";
                  }
                  {
                    name = "channel";
                    value = config.nixpkgs.version;
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
          "Home Manager Options ${config.nixpkgs.version}" = {
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
                    value = config.nixpkgs.version;
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

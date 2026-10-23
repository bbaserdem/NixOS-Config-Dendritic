# Configuring gecko search engines
{config, ...}: {
  flake.modules.homeManager.wolframite-gecko = {
    lib,
    options,
    ...
  }: {
    key = "wolframite-gecko/search#homeManager";
    config = lib.optionalAttrs (options ? gecko) {
      gecko.search = {
        # Default to duck duck go, google is very AI now
        default = "qwant-web";
        privateDefault = "google-web";
        force = true;

        order = [
          "qwant-web" #
          "ddg" # Built-in for all variants
          "google-web" # Custom non-google search
          "ecosia-web"
          "wikipedia" # Built-in for all variants
          "perplexity" # Built-in for firefox; needs to be defined for librewolf
        ];

        # Search providers
        engines = {
          # Qwant search
          qwant-web = {
            name = "Qwant";
            urls = [
              {
                template = "https://www.qwant.com/";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "https://www.qwant.com/favicon.ico";
            definedAliases = ["@q"];
          };
          ecosia-web = {
            name = "Ecosia";
            urls = [
              {
                template = "https://www.ecosia.org/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "https://www.ecosia.org/favicon.ico";
            definedAliases = ["@ec"];
          };
          # Duck-duck-go; builtin available in all modules
          ddg.metaData = {
            alias = "@d";
            hidden = false;
          };
          # Wikipedia; builtin in all modules
          wikipedia.metaData = {
            alias = "@w";
            hidden = false;
          };
          # Google search; remove gemini
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
            definedAliases = ["@nd"];
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

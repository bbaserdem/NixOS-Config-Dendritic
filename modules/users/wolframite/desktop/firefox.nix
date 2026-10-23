# Configuring firefox specific settings for wolframite
{...}: {
  # Configure global firefox settings
  flake.modules.homeManager.wolframite-firefox = {
    pkgs,
    lib,
    options,
    ...
  }: {
    key = "wolframite-firefox#homeManager";
    config = lib.mkMerge [
      (
        lib.optionalAttrs (options ? gecko) {
          gecko.firefox = {
            # Add ublock origin and privacy essentials
            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
              ublock-origin
              duckduckgo-privacy-essentials
            ];
            # Configure built-in search engines
            search.engines = {
              google.metaData = {
                alias = "@gg";
                hidden = false;
              };
              bing.metaData = {
                alias = "@b";
                hidden = true;
              };
              perplexity.metaData = {
                alias = "@p";
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
              ebay.metaData = {
                alias = "@eb";
                hidden = true;
              };
            };
          };
        }
      )
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.firefox = {
            # Darwin doesn't use wrapper, language packs only available in linux
            languagePacks = [
              "en-US"
              "tr"
            ];
          };
        }
      )
      {
        programs.firefox = {
          policies = {
            # Firefox sync should do most things
            Sync = {
              History = true;
              Passwords = true;
              Addresses = true;
              PaymentMethods = true;
            };

            # Unlock the DRM policy
            EncryptedMediaExtensions.Locked = false;

            # Disabling extra telemetry
            DisableFeedbackCommands = true;
            DisablePocket = true;
            DontCheckDefaultBrowser = true;
            NoDefaultBookmarks = true;
            OverrideFirstRunPage = "";
            OverridePostUpdatePage = "";

            # Firefox Suggest / search suggestions / sponsored-ish surfaces.
            SearchSuggestEnabled = false;
            FirefoxSuggest = {
              WebSuggestions = false;
              SponsoredSuggestions = false;
              ImproveSuggest = false;
              Locked = true;
            };

            # Firefox 144 / ESR 140.4-era policy.
            # Mozilla documents this as controlling chatbot, link previews,
            # smart tab groups, etc.
            GenerativeAI = {
              Enabled = false;
              Chatbot = false;
              LinkPreviews = false;
              TabGroups = false;
              Locked = true;
            };

            # First run policy
            Homepage = {
              StartPage = "none";
              Locked = false;
            };

            # Extra hard locks for prefs that either are not covered by a high-level
            # policy, or that you want visibly locked in about:config.
            Preferences = let
              _disabled = {
                Value = false;
                Status = "locked";
              };
              _locked = v: {
                Value = v;
                Status = "locked";
              };
              _default = v: {
                Value = v;
                Status = "default";
              };
            in {
              # Extension management
              "extensions.autoDisableScopes" = _locked 0;
              # Telemetry
              "datareporting.usage.uploadEnabled" = _disabled;
              "browser.discovery.enabled" = _disabled;
              "browser.newtabpage.activity-stream.feeds.telemetry" = _disabled;
              "browser.newtabpage.activity-stream.telemetry" = _disabled;
              "browser.ping-centre.telemetry" = _disabled;
              "datareporting.healthreport.uploadEnabled" = _disabled;
              "datareporting.policy.dataSubmissionEnabled" = _disabled;
              "toolkit.telemetry.archive.enabled" = _disabled;
              "toolkit.telemetry.enabled" = _disabled;
              "toolkit.telemetry.server" = _locked "";
              "toolkit.telemetry.unified" = _disabled;
              # AI
              "browser.ml.enable" = _disabled;
              "extensions.ml.enabled" = _disabled;
              "browser.ml.chat.enabled" = _disabled;
              "browser.ml.chat.page" = _disabled;
              "browser.ml.linkPreview.enabled" = _disabled;
              "browser.tabs.groups.smart.userEnabled" = _disabled;
              "pdfjs.enableAltTextModelDownload" = _disabled;
              "pdfjs.enableGuessAltText" = _disabled;
              # Extra AI belt-and-suspenders
              "browser.ml.chat.sidebar" = _disabled;
              "browser.ml.chat.menu" = _disabled;
              "browser.ml.pageAssist.enabled" = _disabled;
              "browser.ml.smartAssist.enabled" = _disabled;
              "browser.tabs.groups.smart.enabled" = _disabled;
              # DRM / Widevine defaults
              "media.eme.enabled" = _default true;
              "media.gmp-widevinecdm.enabled" = _default true;
              "media.gmp-widevinecdm.visible" = _default true;
              "media.gmp-manager.updateEnabled" = _default true;
              "media.gmp-widevinecdm.autoupdate" = _default true;

              # Don't ask for download dir
              "browser.download.useDownloadDir" = _default true;

              # Disable first-run things
              "browser.download.panel.shown" = _default true;
              "browser.rights.3.shown" = _default true;
              "browser.bookmarks.addedImportButton" = _default true;
              "browser.disableResetPrompt" = _default true;
              "browser.messaging-system.whatsNewPanel.enabled" = _default false;
              "browser.uitour.enabled" = _default false;
            };
          };
        };
      }
    ];
  };
}

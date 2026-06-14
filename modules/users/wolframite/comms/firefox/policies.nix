# Configuring firefox
{...}: {
  # Configure global firefox settings
  flake.modules.homeManager.wolframite = {...}: {
    config = {
      # Firefox policies
      programs.firefox.policies = {
        # Set firefox sync settings
        Sync = {
          Enabled = true;
          Locked = true;

          History = true;
          Passwords = true;
          Addresses = true;
          PaymentMethods = true;
          Bookmarks = true;

          OpenTabs = false;
          Addons = false;
          Settings = false;
        };

        # Disabling telemetry
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
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

        # Important: leave DRM enabled on the profile where you want Prime /
        # Crunchyroll / Netflix. Mozilla documents this as controlling
        # media.eme.enabled / Widevine availability.
        EncryptedMediaExtensions = {
          Enabled = true;
          Locked = false;
        };

        # First run policy
        Homepage = {
          StartPage = "none";
          Locked = false;
        };

        # Firefox Enterprise 149+ AI policy.
        # This is the newer broader AI-control surface. Safe to keep here,
        # but older Firefox versions may ignore unknown policies.
        AIControls = let
          _blocked = {
            Value = "blocked";
            Locked = true;
          };
        in {
          Default = _blocked;
          Translations = _blocked;
          PDFAltText = _blocked;
          SmartTabGroups = _blocked;
          LinkPreviewKeyPoints = _blocked;
          SidebarChatbot = _blocked;
          SmartWindow = _blocked;
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
          "media.gmp-widevinecdm.force-chromium-update" = _default true;

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
  };
}

# Configuring global firefox settings
{...}: {
  localConfig.users.batuhan.firefox.global.settings = {
    # Global settings

    # Behavior
    # Extension management
    "extensions.autoDisableScopes" = 0;
    # Don't ask for download dir
    "browser.download.useDownloadDir" = true;

    # Disable first-run things
    "browser.disableResetPrompt" = true;
    "browser.download.panel.shown" = true;
    "browser.feeds.showFirstRunUI" = false;
    "browser.messaging-system.whatsNewPanel.enabled" = false;
    "browser.rights.3.shown" = true;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.shell.defaultBrowserCheckCount" = 1;
    "browser.startup.homepage_override.mstone" = "ignore";
    "browser.uitour.enabled" = false;
    "startup.homepage_override_url" = "";
    "trailhead.firstrun.didSeeAboutWelcome" = true;
    "browser.bookmarks.restore_default_bookmarks" = false;
    "browser.bookmarks.addedImportButton" = true;

    # Disable telemetry
    "app.shield.optoutstudies.enabled" = false;
    "services.sync.prefs.app.shield.optoutstudies.enabled" = false;
    "browser.discovery.enabled" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "datareporting.healthreport.service.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.sessions.current.clean" = true;
    "devtools.onboarding.telemetry.logged" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.prompted" = 2;
    "toolkit.telemetry.rejected" = true;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.server" = "";
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.unifiedIsOptIn" = false;
    "toolkit.telemetry.updatePing.enabled" = false;

    # Options not to sync
    "services.sync.prefs.sync-seen.browser.firefox-view.feature-tour" = false;
    "services.sync.prefs.sync-seen.browser.startup.homepage" = false;

    # AI Desloppification
    "browser.ml.enable" = false; # general switch for machine learning features in Firefox (https://www.reddit.com/r/firefox/comments/1obbrvz/how_to_completely_get_rid_of_the_ai_stuff/nki10g9/), though it might not completely disable all features (https://bugzilla.mozilla.org/show_bug.cgi?id=1971973#c11)
    "browser.ai.control.default" = "blocked"; # Settings > AI Controls > "Block AI enhancements"
    "browser.ai.control.sidebarChatbot" = "blocked"; # AI Chatbot
    "browser.ml.chat.enabled" = false; # https://docs.openwebui.com/tutorials/integrations/firefox-sidebar/#additional-about-settings
    "browser.ml.chat.sidebar" = false; #
    "browser.ml.chat.menu" = false; # remove "Ask a chatbot" from tab context menu
    "browser.ml.chat.page" = false; # remove option from page context menu
    "extensions.ml.enabled" = false; # might only be relevant for app developers
    "browser.ai.control.linkPreviewKeyPoints" = "blocked";
    "browser.ml.linkPreview.enabled" = false;
    "browser.ml.pageAssist.enabled" = false;
    "browser.ml.smartAssist.enabled" = false;
    "browser.ai.control.smartTabGroups" = "blocked";
    "browser.tabs.groups.smart.enabled" = false; # "Use AI to suggest tabs and a name for tab groups" in settings
    "browser.tabs.groups.smart.userEnabled" = false;
    "browser.ai.control.translations" = "blocked"; # AI translations
    "browser.ai.control.pdfjsAltText" = "blocked"; # "When you add images to PDFs, this adds descriptions to make them accessible." (https://support.mozilla.org/en-US/kb/pdf-alt-text?#w_add-alt-text-automatically)
    "pdfjs.enableAltTextModelDownload" = false; # "This prevents downloading the AI model unless the user opts in (by enabling the toggle to "Create alt text automatically" from "Image alt text settings" when viewing a PDF)"]
    "pdfjs.enableGuessAltText" = false; # (disabling this might be redundant when AltTextModelDownload is disabled)
  };
}

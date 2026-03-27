# Configuring firefox preferences
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
    programs.firefox.profiles.batuhan.settings = {
      # Set startup page; with different containers
      "network.protocol-handler.external.ext+container" = true;
      "browser.startup.homepage" = pkgs.lib.strings.concatStringsSep "|" [
        "http://127.0.0.1:8384/"
        "ext+container:name=Work&url=https://mail.google.com/mail/u/0/#inbox"
        "https://mail.google.com/mail/u/0/#inbox"
      ];
      "services.sync.prefs.sync-seen.browser.startup.homepage" = false;

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

      # Don't ask for download dir
      "browser.download.useDownloadDir" = true;

      # Disable telemetry

      # Disable some telemetry
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
    };
  };
}

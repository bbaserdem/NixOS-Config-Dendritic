# Configuring firefox layout
{...}: {
  flake.modules.home-manager.firefox = {...}: {
    programs.firefox.profiles.default.settings = {
      "browser.uiCustomization.state" = builtins.toJSON {
        currentVersion = 24;
        newElementCount = 13;
        dirtyAreaCache = [
          "nav-bar"
          "vertical-tabs"
          "PersonalToolbar"
          "unified-extensions-area"
          "toolbar-menubar"
          "TabsToolbar"
          "widget-overflow-fixed-list"
        ];
        placements = {
          nav-bar = [
            "firefox-view-button"
            "back-button"
            "forward-button"
            "stop-reload-button"
            "urlbar-container"
            "_testpilot-containers-browser-action"
            "bookmarks-menu-button"
            "history-panelmenu"
            "downloads-button"
            "sidebar_button"
            "unified-extensions-button"
          ];
          PersonalToolbar = [
            "search-container"
            "zoom-controls"
            # Dunno
            "_8a3715dc-7333-46d9-a133-a378fa5625bd_-browser-action"
            # Ublock origin
            "ublock0_raymondhill_net-browser-action"
            # Remove overlay
            "_c0e1baea-b4cb-4b62-97f0-278392ff8c37_-browser-action"
            # Zotero connector
            "zotero_chnm_gmu_edu-browser-action"
            # Video DownloadHelper
            "_b9db16a4-6edc-47ec-a1f4-b86292ed211d_-browser-action"
            # Kodi cast
            "castkodi_regseb_github_io-browser-action"
            # Geo control
            "_ad6b7cbf-38b5-4399-8f16-d56855de1f68_-browser-action"
            # Mullvad vpn
            "_d19a89b9-76c1-4a61-bcd4-49e8de916403_-browser-action"
            # Greasemonkey
            "_e4a8a97b-f2ed-450b-b12d-ee082ba24781_-browser-action"
            # Containarize
            "containerise_kinte_sh-browser-action"
            # Bookmarks
            "personal-bookmarks"
          ];
          TabsToolbar = [
            "tabbrowser-tabs"
            "new-tab-button"
            "alltabs-button"
            "tab-array_menhera_org-browser-action"
          ];
          toolbar-menubar = [
            "menubar-items"
          ];
          unified-extensions-area = [
            "_3c9b993f-29b9-44c2-a913-def7b93a70b1_-browser-action"
            "_44df5123-f715-9146-bfaa-c6e8d4461d44_-browser-action"
            "_d44fa1f9-1400-401d-a79e-650d466ec6d6_-browser-action"
            "containertabssidebar_maciekmm_net-browser-action"
            "dontfuckwithpaste_raim_ist-browser-action"
            "_5cce4ab5-3d47-41b9-af5e-8203eea05245_-browser-action"
            "_72bd91c9-3dc5-40a8-9b10-dec633c0873f_-browser-action"
            "uget-integration_slgobinath-browser-action"
            "user-agent-switcher_ninetailed_ninja-browser-action"
            "chrome-gnome-shell_gnome_org-browser-action"
            "_4b547b2c-e114-4344-9b70-09b2fe0785f3_-browser-action"
            "plasma-browser-integration_kde_org-browser-action"
            "_bbb880ce-43c9-47ae-b746-c3e0096c5b76_-browser-action"
            "dfyoutube_example_com-browser-action"
            "jid1-tsgsxbhncspbwq_jetpack-browser-action"
            "_a1541a5e-68f8-480d-8f10-784f93079060_-browser-action"
            "_25d049c4-af50-480c-bea8-09fc8bcc5323_-browser-action"
            "firefox-extension_steamdb_info-browser-action"
            "languagetool-webextension_languagetool_org-browser-action"
            "jid1-zadieub7xozojw_jetpack-browser-action"
            "_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action"
          ];
          widget-overflow-fixed-list = [];
        };
        seen = [
          "save-to-pocket-button"
          "developer-button"
          "_3c9b993f-29b9-44c2-a913-def7b93a70b1_-browser-action"
          "_44df5123-f715-9146-bfaa-c6e8d4461d44_-browser-action"
          "_d44fa1f9-1400-401d-a79e-650d466ec6d6_-browser-action"
          "_c0e1baea-b4cb-4b62-97f0-278392ff8c37_-browser-action"
          "browserpass_maximbaz_com-browser-action"
          "containertabssidebar_maciekmm_net-browser-action"
          "dontfuckwithpaste_raim_ist-browser-action"
          "_5cce4ab5-3d47-41b9-af5e-8203eea05245_-browser-action"
          "_72bd91c9-3dc5-40a8-9b10-dec633c0873f_-browser-action"
          "_testpilot-containers-browser-action"
          "uget-integration_slgobinath-browser-action"
          "user-agent-switcher_ninetailed_ninja-browser-action"
          "chrome-gnome-shell_gnome_org-browser-action"
          "_e4a8a97b-f2ed-450b-b12d-ee082ba24781_-browser-action"
          "_d19a89b9-76c1-4a61-bcd4-49e8de916403_-browser-action"
          "_4b547b2c-e114-4344-9b70-09b2fe0785f3_-browser-action"
          "sponsorblocker_ajay_app-browser-action"
          "ublock0_raymondhill_net-browser-action"
          "_b9db16a4-6edc-47ec-a1f4-b86292ed211d_-browser-action"
          "zotero_chnm_gmu_edu-browser-action"
          "_ad6b7cbf-38b5-4399-8f16-d56855de1f68_-browser-action"
          "plasma-browser-integration_kde_org-browser-action"
          "bukubrow_samhh_com-browser-action"
          "castkodi_regseb_github_io-browser-action"
          "containerise_kinte_sh-browser-action"
          "tab-array_menhera_org-browser-action"
          "_bbb880ce-43c9-47ae-b746-c3e0096c5b76_-browser-action"
          "dfyoutube_example_com-browser-action"
          "jid1-tsgsxbhncspbwq_jetpack-browser-action"
          "_a1541a5e-68f8-480d-8f10-784f93079060_-browser-action"
          "_25d049c4-af50-480c-bea8-09fc8bcc5323_-browser-action"
          "firefox-extension_steamdb_info-browser-action"
          "_8a3715dc-7333-46d9-a133-a378fa5625bd_-browser-action"
          "languagetool-webextension_languagetool_org-browser-action"
          "jid1-zadieub7xozojw_jetpack-browser-action"
          "_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action"
          "screenshot-button"
        ];
      };
    };
  };
}

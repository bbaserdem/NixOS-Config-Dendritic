# Su-ana desktop config
{inputs, ...}: {
  flake.modules.darwin.su-ana = {config, ...}: let
    username = "batuhan";
    hmDir = "${config.users.users.${username}.home}/Applications/Home Manager Apps";
  in {
    # System configuration

    # Load modules for desktop configuration
    imports = with inputs.self.modules.darwin; [
      fonts
      keyboard
      stylix
    ];

    # System behavior settings
    system = {
      defaults = {
        # General behavior
        NSGlobalDomain = {
          "com.apple.mouse.tapBehavior" = 1;
          "com.apple.sound.beep.volume" = 0.0;
          "com.apple.sound.beep.feedback" = 0;
        };
        # Dock settings
        dock = {
          autohide = true;
          autohide-delay = 0.1;
          largesize = 32;
          launchanim = true;
          minimize-to-application = true;
          mouse-over-hilite-stack = true;
          orientation = "left";
          show-recents = false;
          showhidden = true;
          tilesize = 48;
          # Hot corner actions
          wvous-tr-corner = 1; # Nothing
          wvous-tl-corner = 2; # Mission control
          wvous-bl-corner = 3; # Application Windows
          wvous-br-corner = 12; # Notification Center
          # Items
          # TODO: Switch this to dockutil user-level later
          persistent-apps = [
            # System
            {app = "/System/Applications/Home.app/";}
            {app = "/System/Applications/System Settings.app/";}
            {app = "/System/Applications/Utilities/Activity Monitor.app/";}
            {app = "/Applications/WorkSmart.app/";}
            {app = "${hmDir}/KeePassXC.app/";}
            {spacer = {small = true;};}
            # Media
            {app = "/Applications/foobar2000.app/";}
            {app = "/Applications/swmpc.app/";}
            {app = "/Applications/VLC.app/";}
            {app = "/Applications/OBS.app/";}
            {app = "/Applications/Steam.app/";}
            {spacer = {small = true;};}
            # Documents
            {app = "${hmDir}/Obsidian.app/";}
            {app = "${hmDir}/Zotero.app/";}
            {app = "${hmDir}/Neovide.app/";}
            {app = "/Applications/LibreOffice.app/";}
            {spacer = {small = true;};}
            # Internet
            {app = "/System/Applications/Mail.app/";}
            {app = "${hmDir}/Slack.app/";}
            {app = "/Applications/Google Chrome.app/";}
            {app = "/Applications/Chromium.app/";}
            {app = "/Applications/Firefox.app/";}
            {spacer = {small = true;};}
            # Dev
            {app = "/Applications/GitHub Desktop.app/";}
            {app = "${hmDir}/kitty.app/";}
            {app = "/Applications/Ghostty.app/";}
            {app = "${hmDir}/OrbStack.app/";}
            {app = "${hmDir}/UTM.app/";}
            {spacer = {small = true;};}
            # AI
            {app = "/Applications/Repo Prompt.app/";}
            {app = "/Applications/Claude.app/";}
            {app = "/Applications/Codex.app/";}
          ];
        };
        iCal = {
          CalendarSidebarShown = true;
        };
        trackpad = {
          Clicking = true;
          TrackpadThreeFingerDrag = true;
        };
        screencapture = {
          # location = "";
          type = "png";
        };
      };
      keyboard = {
        remapCapsLockToControl = true;
      };
    };
  };
}

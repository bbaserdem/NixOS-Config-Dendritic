# Module for desktop behavior for wolframite
{inputs, ...}: {
  den = {
    aspects.wolframite = {
      # Dispatched automatically by den.aspects.system.ploicies.user-macos-config-dispatch
      provides.macos = {
        host,
        user,
      }: {
        name = "wolframite/macos(${user.userName}@${host.name})";
        darwin = {lib, ...}: {
          imports = with inputs.self.modules.darwin; [
            wolframite-macos-behavior
          ];
          config = {
            # Dock config
            # TODO: Add conditional switches to app presence
            system.defaults.dock.persistent-apps = let
              hmDir = "${user.homeDirectory}/Applications/Home Manager Apps";
            in (
              # System apps
              [
                {app = "/System/Applications/System Settings.app/";}
                {app = "/System/Applications/Utilities/Activity Monitor.app/";}
                {app = "${hmDir}/KeePassXC.app/";}
              ]
              # Work-only apps
              ++ lib.optionals (host.name == "su-ana") [
                {app = "/Applications/WorkSmart.app/";}
                {app = "/Applications/Nessie.app/";}
              ]
              ++ [{spacer = {small = true;};}]
              # Media
              ++ [
                {app = "/Applications/foobar2000.app/";}
                {app = "/Applications/swmpc.app/";}
                {app = "${hmDir}/VLC.app/";}
                {app = "/Applications/OBS.app/";}
              ]
              ++ [{spacer = {small = true;};}]
              # Documents
              ++ [
                {app = "${hmDir}/Obsidian.app/";}
                {app = "${hmDir}/Zotero.app/";}
                {app = "${hmDir}/Neovide.app/";}
                {app = "/Applications/LibreOffice.app/";}
              ]
              ++ [{spacer = {small = true;};}]
              # Web
              ++ [
                {app = "/System/Applications/Mail.app/";}
                {app = "${hmDir}/Slack.app/";}
                {app = "${hmDir}/zoom.us.app/";}
                {app = "/Applications/Google Chrome.app/";}
                {app = "${hmDir}/LibreWolf.app/";}
                {app = "/Applications/legcord.app/";}
                {spacer = {small = true;};}
              ]
              ++ [{spacer = {small = true;};}]
              # Dev
              ++ [
                {app = "/Applications/GitHub Desktop.app/";}
                {app = "/Applications/Ghostty.app/";}
                {app = "${hmDir}/OrbStack.app/";}
              ]
              ++ [{spacer = {small = true;};}]
              # AI
              ++ [
                {app = "/Applications/Claude.app/";}
                {app = "/Applications/OpenCode.app/";}
              ]
              ++ [{spacer = {small = true;};}]
            );
          };
        };
      };
    };
  };

  flake.modules.darwin = {
    wolframite-macos-behavior = {...}: {
      key = "wolframite-macos-behavior#homeManager";
      config = {
        # System behavior settings
        system = {
          # General behavior
          defaults = {
            NSGlobalDomain = {
              "com.apple.mouse.tapBehavior" = 1;
              "com.apple.sound.beep.volume" = 0.0;
              "com.apple.sound.beep.feedback" = 0;
            };
            iCal = {
              CalendarSidebarShown = true;
            };
            trackpad = {
              Clicking = true;
              TrackpadThreeFingerDrag = true;
            };
            menuExtraClock = {
              Show24Hour = true;
            };
            screencapture = {
              # location = "";
              type = "png";
            };
            dock = {
              autohide = true;
              autohide-delay = 0.1;
              largesize = 32;
              launchanim = true;
              minimize-to-application = true;
              mouse-over-hilite-stack = true;
              orientation = "bottom";
              show-recents = false;
              showhidden = true;
              tilesize = 48;
              # Hot corner actions
              wvous-tr-corner = 1; # Nothing
              wvous-tl-corner = 2; # Mission control
              wvous-bl-corner = 3; # Application Windows
              wvous-br-corner = 12; # Notification Center
            };
          };
          keyboard = {
            enableKeyMapping = true;
            remapCapsLockToControl = true;
          };
        };
      };
    };
  };
}

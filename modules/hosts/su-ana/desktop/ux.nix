# Su-ana UX behavior
{...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System behavior settings
    system = {
      defaults = {
        # General behavior
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

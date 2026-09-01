# Configuring OS defaults for macos systems
{...}: {
  # TODO: These settings should be migrated to a wolframite specific module
  flake.modules.darwin.macos-settings = {...}: {
    system = {
      # Don't need this with flakes
      checks.verifyNixPath = false;
      defaults = {
        LaunchServices = {
          LSQuarantine = false;
        };
        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          ApplePressAndHoldEnabled = false;

          # 120, 90, 60, 30, 12, 6, 2
          KeyRepeat = 2;

          # 120, 94, 68, 35, 25, 15
          InitialKeyRepeat = 15;
        };
        finder = {
          _FXShowPosixPathInTitle = true;
        };
        loginwindow = {
          DisableConsoleAccess = false;
          GuestEnabled = false;
        };
        menuExtraClock = {
          Show24Hour = true;
        };
        screencapture = {
          # location = "";
          type = "png";
        };
      };
      keyboard = {
        enableKeyMapping = true;
      };
    };
  };
}

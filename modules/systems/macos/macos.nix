# Configuring macos systems
{...}: {
  flake.modules.darwin.macos = {lib, ...}: {
    # Create new option meta.defaultUser that can be used with other modules
    # Mirrors the "to-be-deprecated" system.primaryUser option
    options = {
      system.mainUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          The user that can be configured by modules in this flake.
        '';
      };
    };

    config = {
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
  };
}

# Configuring librewolf global policy settings
{...}: {
  flake.modules.homeManager.wolframite-librewolf = {...}: {
    config = {
      # Librewolf policies
      programs.librewolf.policies = {
        # Set librewolf sync settings
        Sync = {
          Enabled = true;
          Locked = true;

          History = true;
          Passwords = false;
          Addresses = false;
          PaymentMethods = false;
          Bookmarks = true;

          OpenTabs = false;
          Addons = false;
          Settings = false;
        };

        # Disabling telemetry
        DisableTelemetry = true;
        DisableFirefoxStudies = true;

        # Needed for DRM
        EncryptedMediaExtensions = {
          Enabled = true;
          Locked = true;
        };

        # Block notification request windows
        Permissions.Notifications = {
          BlockNewRequests = true;
          Locked = true;
        };

        Preferences = {
          # Auto-enable nix installed extensions
          "extensions.autoDisableScopes" = {
            Value = 0;
            Status = "locked";
          };
          # Disable accessibility features
          "accessibility.force_disabled" = {
            Value = 1;
            Status = "locked";
          };
          # Disable desktop notification feature
          "permissions.default.desktop-notification" = {
            Value = 2;
            Status = "locked";
          };
        };

        # Block every ai feature
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
      };
    };
  };
}

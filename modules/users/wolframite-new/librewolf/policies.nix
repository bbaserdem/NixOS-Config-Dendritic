# Configuring librewolf global policy settings
{...}: {
  flake.modules.homeManager.librewolf-wolframite = {...}: {
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
          Locked = false;
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

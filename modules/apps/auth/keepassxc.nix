# Keepassxc configuration
{...}: {
  flake.modules.homeManager.keepassxc = {pkgs, ...}: {
    programs.keepassxc = {
      # Common settings
      enable = true;

      settings = {
        General = {
          ConfigVersion = 2;
          MinimizeAfterUnlock = false;
        };

        Browser = {
          Enabled = true;
          CustomProxyLocation = false;
          UpdateBinaryPath = false;
          AlwaysAllowAccess = true;
          AlwaysAllowUpdate = true;
        };

        GUI = {
          AdvancedSettings = true;
          ColorPasswords = true;
          CompactMode = true;
          HidePasswords = true;
          MinimizeOnClose = true;
          MinimizeOnStartup = true;
          MinimizeToTray = true;
          ShowTrayIcon = true;
          TrayIconAppearance = "colorful";
        };

        PasswordGenerator = {
          AdditionalChars = "";
          ExcludedChars = "";
        };

        SSHAgent.Enabled = true;
      };
    };

    home.packages = with pkgs; [
      kpcli
    ];
  };
}

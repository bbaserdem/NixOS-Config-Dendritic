# Keepassxc
{inputs, ...}: {
  # Aspect
  den = {
    aspects.desktop = {
      provides.keepassxc = {
        name = "keepassxc/keepassxc";
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/keepassxc(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.keepassxc-settings
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.keepassxc-settings = {pkgs, ...}: {
    key = "keepassxc-settings#homeManager";
    config = {
      programs.keepassxc = {
        enable = true;
        # Common settings
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
      # CLI tooling as well
      home.packages = with pkgs; [
        kpcli
      ];
    };
  };
}

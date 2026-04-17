# Keepassxc
{...}: {
  flake.modules.homeManager.keepassxc = {
    pkgs,
    lib,
    ...
  }: {
    programs.keepassxc = lib.mkMerge [
      {
        # Common settings
        enable = true;
        settings = {
          General = {
            ConfigVersion = 2;
            MinimizeAfterUnlock = true;
          };
          PasswordGenerator = {
            AdditionalChars = "";
            ExcludedChars = "";
          };
          Browser = {
            Enabled = true;
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
          SSHAgent.Enabled = true;
        };
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        # Linux-only settings
        autostart = true;
        settings.Browser = {
          CustomProxyLocation = false;
          UpdateBinaryPath = false;
          AlwaysAllowAccess = true;
          AlwaysAllowUpdate = true;
        };
      })
    ];
  };
}

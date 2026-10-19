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
  flake.modules.homeManager.keepassxc-settings = {
    pkgs,
    lib,
    config,
    ...
  }: {
    key = "keepassxc-settings#homeManager";
    config = {
      programs =
        {
          keepassxc = {
            enable = true;
            autostart = pkgs.stdenv.hostPlatform.isLinux;
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
              Security = {
                IconDownloadFallback = true;
              };
              SSHAgent.Enabled = true;
            };
          };
        }
        // (
          lib.genAttrs
          ["firefox" "librewolf" "chromium"]
          (_: {nativeMessagingHosts = [config.programs.keepassxc.package];})
        );
      # CLI tooling as well
      home.packages = with pkgs; [
        kpcli
      ];
    };
  };
}

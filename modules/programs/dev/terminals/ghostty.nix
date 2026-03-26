# Configuring ghostty
{...}: {
  flake.modules.home-manager = {
    # Enable stylix theming for ghostty
    stylix = {...}: {
      stylix.targets.ghostty = {
        enable = true;
      };
    };

    # Kitty settings
    ghostty = {
      pkgs,
      lib,
      ...
    }: {
      programs.ghostty = lib.mkMerge [
        {
          enable = true;

          # Integrations
          enableBashIntegration = true;
          enableZshIntegration = true;
          installVimSyntax = true;
          installBatSyntax = true;

          # Settings
          settings = {
            theme = "light:Belafonte Day,dark:Belafonte Night";
          };
        }
        (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # Linux only settings
          systemd = {
            enable = true;
          };
          settings = {
            linux-cgroup = "single-instance";
          };
        })
        (lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          # MacOS only settings
          settings = {
            macos-option-as-alt = true;
            macos-icon = "microchip";
          };
        })
      ];
    };
  };
}

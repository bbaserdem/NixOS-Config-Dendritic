# Configuring ghostty
{...}: {
  flake.modules.homeManager = {
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
          installVimSyntax = true;
          installBatSyntax = true;

          # Settings
          settings = {
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
          };
        })
      ];
    };
  };
}

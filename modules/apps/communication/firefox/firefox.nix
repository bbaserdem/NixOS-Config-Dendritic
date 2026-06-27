# Enabling shared firefox module
{...}: {
  flake.modules = {
    # Home-manager configuration
    homeManager = {
      # Stylix theming for firefox
      stylix = {...}: {
        stylix.targets.firefox = {
          enable = true;
          colorTheme.enable = true;
          firefoxGnomeTheme.enable = true;
        };
      };

      # Firefox install
      firefox = {
        pkgs,
        lib,
        ...
      }: {
        config = lib.mkMerge [
          {
            programs.firefox.enable = true;
          }
          (
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              programs.firefox.package = pkgs.firefox;
            }
          )
          (
            # TODO: REmove this quickfix; firefox-unwrapped hydra failure 27-06-2026
            lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
              programs.firefox.package = pkgs.firefox-bin;
            }
          )
        ];
      };
    };
  };
}

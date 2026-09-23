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
          # TODO: Testing this
          firefoxGnomeTheme.enable = false;
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
            lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
              programs.firefox.package = pkgs.firefox;
            }
          )
        ];
      };
    };
  };
}

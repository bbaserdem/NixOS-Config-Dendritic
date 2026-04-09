# Enabling shared firefox module
{...}: {
  flake.modules = {
    homeManager = {
      # Stylix theming for firefox
      stylix = {...}: {
        stylix.targets.firefox = {
          enable = true;
          colorTheme.enable = true;
          firefoxGnomeTheme.enable = true;
          profileNames = [
            "default"
          ];
        };
      };

      # Firefox install
      firefox = {
        pkgs,
        lib,
        ...
      }: {
        # Use firefox-bin in the package
        config = lib.mkMerge [
          (
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              programs.firefox = {
                package = pkgs.firefox;
              };
            }
          )
          (
            lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
              programs.firefox = {
                package = pkgs.firefox-bin;
              };
            }
          )
        ];
      };
    };
  };
}

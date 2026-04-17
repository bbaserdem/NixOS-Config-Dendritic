# Enabling shared firefox module
{...}: {
  flake.modules = {
    # Install firefox through brew in darwin
    # darwin.firefox = {...}: {
    #   homebrew.casks = [
    #     "firefox"
    #   ];
    # };

    # Home-manager configuration
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
          {
            programs.firefox = {
              enable = true;
              package = pkgs.firefox;
            };
          }
          # (
          #   lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          #     programs.firefox = {
          #       package = pkgs.firefox;
          #     };
          #   }
          # )
          # (
          #   lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          #     programs.firefox = {
          #       # In darwin, the home-manager installation doesn't work
          #       # Install through brew
          #       package = null;
          #     };
          #   }
          # )
        ];
      };
    };
  };
}

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
        ];
      };
    };
  };
}

# Configuring yazi
{...}: {
  flake.modules = {
    # Provide binary for mactag.yazi to work on mac
    darwin.yazi = {...}: {
      homebrew.brews = [
        "tag"
      ];
    };

    # General dispatch module
    homeManager = {
      # Stylix theming
      stylix = {...}: {
        stylix.targets.yazi = {
          boldDirectory = true;
          enable = true;
        };
      };

      # Yazi config; rest is handled by the wrapper
      yazi = {...}: {
        programs.yazi.enable = true;
      };
    };
  };
}

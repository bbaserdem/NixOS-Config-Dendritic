# Enabling shared firefox module
{...}: {
  flake.modules.homeManager = {
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
  };
}

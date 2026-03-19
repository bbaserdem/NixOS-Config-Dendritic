# Enabling stylix theming for firefox
{...}: {
  flake.modules.home-manager.stylix = {...}: {
    stylix.targets.firefox = {
      enable = true;
      colorTheme.enable = true;
      firefoxGnomeTheme.enable = true;
      profileNames = [
        "default"
      ];
    };
  };
}

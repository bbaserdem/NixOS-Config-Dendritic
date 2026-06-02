# Geoclue; network location
{...}: {
  flake.modules.nixos.geoclue = {...}: {
    services.geoclue2 = {
      enable = true;
      # Common apps to allow
      appConfig = {
        redshift = {
          isAllowed = true;
          isSystem = false;
        };
        gammastep = {
          isAllowed = true;
          isSystem = false;
        };
      };
    };
  };
}

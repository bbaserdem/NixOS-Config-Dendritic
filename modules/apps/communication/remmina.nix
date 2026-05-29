# Enabling remmina in the background
{...}: {
  flake.modules = {
    homeManager.remmina = {...}: {
      services.remmina = {
        enable = true;
        systemdService = {
          enable = true;
        };
        addRdpMimeTypeAssoc = true;
      };
    };
  };
}

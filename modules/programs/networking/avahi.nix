# Avahi; zeroconf network discovery
{...}: {
  flake.modules.nixos.avahi = {...}: {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}

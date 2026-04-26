# Rasdaemon; hardware event logger
{...}: {
  flake.modules.nixos.rasdaemon = {...}: {
    hardware.rasdaemon = {
      enable = true;
    };
  };
}

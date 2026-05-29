# Udev, hardware management
{...}: {
  flake.modules.nixos.nixos = {...}: {
    services.udev = {
      enable = true;
    };
  };
}

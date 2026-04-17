# Udev, hardware management
{...}: {
  flake.modules.nixos.udev = {...}: {
    services.udev = {
      enable = true;
    };
  };
}

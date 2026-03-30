# Firmware updater daemon
{...}: {
  flake.modules.nixos.firmware = {...}: {
    services.fwupd = {
      enable = true;
    };
  };
}

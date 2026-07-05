# Firmware updater daemon
# TODO: nuke this, absorb into nixos module probably
{...}: {
  flake.modules.nixos.firmware = {...}: {
    services.fwupd = {
      enable = true;
    };
  };
}

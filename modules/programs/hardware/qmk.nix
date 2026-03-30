# QMK keyboard udev setup
{...}: {
  flake.modules.nixos.qmk = {...}: {
    hardware.keyboard.qmk = {
      enable = true;
    };
  };
}

# Managing qmk keyboards availability in nixos
{...}: {
  flake.modules.nixos.hardware-qmk = {...}: {
    key = "hardware-qmk#nixos";
    config = {
      hardware.keyboard.qmk = {
        enable = true;
        keychronSupport = true;
      };
    };
  };
}

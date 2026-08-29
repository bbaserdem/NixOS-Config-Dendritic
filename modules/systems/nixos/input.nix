# Nixos; input settings
{...}: {
  flake.modules.nixos.nixos-keyboard = {...}: {
    # Default my systems to dvorak
    services.xserver.xkb = {
      layout = "us,tr,us";
      variant = "dvorak-alt-intl,f,altgr-intl";
      options = "grp:alt_caps_toggle";
    };

    # Enable uinput; kernel interface for synthesizing inputs
    hardware.uinput.enable = true;
  };
}

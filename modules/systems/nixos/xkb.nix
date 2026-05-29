# Nixos; system wide (low level) keyboard settings
{...}: {
  flake.modules.nixos.nixos = {...}: {
    services.xserver.xkb = {
      layout = "us,tr,us";
      variant = "dvorak-alt-intl,f,altgr-intl";
      options = "grp:alt_caps_toggle";
    };
  };
}

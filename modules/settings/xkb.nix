# XKB settings for full system
{...}: {
  flake.modules.nixos.xkb = {...}: {
    services.xserver.xkb = {
      layout = "us,tr,us";
      variant = "dvorak-alt-intl,f,altgr-intl";
      options = "grp:alt_caps_toggle";
    };
  };
}

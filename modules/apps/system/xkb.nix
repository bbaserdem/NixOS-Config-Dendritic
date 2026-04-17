# XKB settings for underlying system; for login elements etc.
{...}: {
  flake.modules = {
    nixos.xkb = {...}: {
      services.xserver.xkb = {
        layout = "us,tr,us";
        variant = "dvorak-alt-intl,f,altgr-intl";
        options = "grp:alt_caps_toggle";
      };
    };
  };
}

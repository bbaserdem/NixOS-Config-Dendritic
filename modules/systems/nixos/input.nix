# Nixos; input settings
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Host schema for declaring system-wide xkb keymap defaults
    schema.host = {
      options = {
        xkb = lib.mkOption {
          description = "Default XKB settings for NixOS. (Follows services.xserver.xkb)";
          default = {};
          type = lib.types.submodule {
            options = {
              layout = lib.mkOption {
                description = "XKB keyboard layout";
                type = lib.types.str;
                default = "us,tr,us";
              };
              variant = lib.mkOption {
                description = "XKB keyboard layout variant";
                type = lib.types.str;
                default = "dvorak-alt-intl,f,altgr-intl";
              };
              options = lib.mkOption {
                description = "XKB keyboard layout options";
                type = lib.types.str;
                default = "grp:alt_caps_toggle";
              };
            };
          };
        };
      };
    };

    # Aspect
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.input
        ];
        provides.input = {host}: {
          name = "system/nixos/input(#${host.name})";
          nixos = {...}: {
            config = {
              services.xserver = {
                inherit (host) xkb;
              };
            };
          };
        };
      };
    };
  };
}

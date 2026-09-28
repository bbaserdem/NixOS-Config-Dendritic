# Nixos locale setting
{
  den,
  lib,
  ...
}: {
  den = {
    # Host schema addition for locale
    schema.host = {
      options = {
        localeSettings = lib.mkOption {
          description = "Locale settings for this host to set i18n to. (NixOS)";
          type = lib.types.attrs;
          default = {
            defaultCharset = "UTF-8";
            defaultLocale = "en_US.UTF-8";
            extraLocales = [
              "C.UTF-8/UTF-8"
              "tr_TR.UTF-8/UTF-8"
            ];
            extraLocaleSettings = {
              # System language
              LANGUAGE = "en_US";
              LC_MESSAGES = "en_US.UTF-8";
              # Time and units
              LC_TIME = "en_DK.UTF-8";
              LC_MEASUREMENT = "en_DK.UTF-8";
              # Dev tooling behavior
              LC_NUMERIC = "en_US.UTF-8";
              LC_COLLATE = "C.UTF-8";
              LC_CTYPE = "en_US.UTF-8";
              # Other stuff
              LC_ADDRESS = "en_US.UTF-8";
              LC_MONETARY = "en_US.UTF-8";
              LC_NAME = "en_US.UTF-8";
              LC_PAPER = "en_US.UTF-8";
              LC_TELEPHONE = "en_US.UTF-8";
            };
          };
        };
      };
    };

    # Aspect dispatch
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.locale
        ];
        provides.locale = {host}: {
          name = "system/nixos/locale(@${host.name})";
          nixos = {...}: {
            # We don't have a seperate module to import
            config = {
              i18n = host.localeSettings;
            };
          };
        };
      };
    };
  };
}

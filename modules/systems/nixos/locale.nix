# Nixos systems locale settings
{...}: {
  flake.modules.nixos.nixos = {...}: {
    i18n = {
      supportedLocales = [
        "C.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "en_DK.UTF-8/UTF-8"
      ];
      defaultLocale = "en_US.UTF-8";
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
}

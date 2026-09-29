# Configuring config for package managers
{den, ...}: {
  # Aspect config
  den = {
    aspects.development = {
      # Auto-include us
      includes = [
        den.aspects.development._.languages
      ];
      provides.languages = {
        name = "development/languages";
      };
    };
  };
}

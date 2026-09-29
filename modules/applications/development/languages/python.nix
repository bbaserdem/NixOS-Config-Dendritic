# Configuring python
{
  inputs,
  den,
  ...
}: {
  # Aspect config
  den = {
    aspects.development = {
      provides.languages = {
        includes = [
          den.aspects.development._.languages._.python
        ];
        provides.lean = {
          name = "development/languages/python";
          provides.to-users = {
            user,
            host,
          }: {
            name = "development/languages/python(${user.userName}@${host.name})";
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.languages-python
              ];
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.languages-python = {...}: {
    key = "languages-python#homeManager";
    config = {
      # Set global configuration for uv without installing it
      programs.uv = {
        enable = true;
        package = null;
        settings = {
          exclude-newer = "1 week";
        };
      };
    };
  };
}

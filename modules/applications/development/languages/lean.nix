# Configuring elan, lean package manager
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
          den.aspects.development._.languages._.lean
        ];
        provides.lean = {
          name = "development/languages/lean";
          provides.to-users = {
            user,
            host,
          }: {
            name = "development/languages/lean(${user.userName}@${host.name})";
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.languages-lean
              ];
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.languages-lean = {config, ...}: {
    key = "languages-lean#homeManager";
    config = {
      # Define global lean install directory
      home.sessionVariables = {
        "ELAN_HOME" = "${config.xdg.dataHome or "${config.home.homeDirectory}/.local/share"}/elan";
      };
    };
  };
}

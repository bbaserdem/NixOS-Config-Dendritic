# Yazi, terminal file manager
{inputs, ...}: {
  # Den dispatch
  den = {
    aspects.applications = {
      provides.yazi = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/yazi(${user.userName}@${host.name})";
          # Modules dispatch
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.yazi-settings
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.yazi-wrapper
              inputs.self.modules.homeManager.yazi-settings
            ];
          };
          # Stylix theming; wrapper pulls from this
          stylix = {
            targets.yazi = {
              enable = true;
              boldDirectory = true;
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Wrapper module
    homeManager.yazi-wrapper = {
      config,
      lib,
      options,
      ...
    }: {
      key = "yazi-wrapper#homeManager";
      imports = [
        inputs.self.wrappers.yazi.install
      ];
      config = lib.mkMerge [
        {
          # Override the main yazi module package with ours
          programs.yazi.package = config.wrappers.yazi.wrapper;
        }
        (
          # Pull the stylix set theme into the wrapper if available
          lib.optionalAttrs (lib.hasAttrByPath ["stylix"] options) {
            wrappers.yazi.settings.theme = config.programs.yazi.theme;
          }
        )
      ];
    };

    # Provide binary for mactag.yazi to work on mac
    darwin.yazi-settings = {...}: {
      key = "yazi-settings#darwin";
      config = {
        homebrew.brews = [
          "tag"
        ];
      };
    };

    # General settings module
    homeManager.yazi-settings = {...}: {
      key = "yazi-settings#homeManager";
      imports = [
        inputs.self.modules.homeManager.yazi-wrapper
      ];
      config = {
        programs.yazi.enable = true;
      };
    };
  };
}

# Configuring firefox
{...}: {
  # Define profiles
  localConfig.users.wolframite.firefox = {
    # Global settings
    # Different profiles
    profiles = {
      personal = {
        id = 0;
        isDefault = true;
        containersForce = true;
      };

      work = {
        id = 1;
        containersForce = true;
      };

      explicit = {
        id = 2;
        containersForce = true;
      };
    };
  };

  # Configure global firefox settings
  flake.modules.homeManager.wolframite = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        # Global configs here
      }
      (
        # Darwin doesn't use the wrapper, can't use the language packs
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux)
        {
          programs.firefox = {
            # Include languages
            languagePacks = [
              "en-US"
              "tr"
            ];
          };
        }
      )
    ];
  };
}

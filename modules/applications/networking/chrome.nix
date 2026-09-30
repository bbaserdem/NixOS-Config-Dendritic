# Chrome and derivatives install setup
{inputs, ...}: {
  # Den
  den = {
    aspects.networking = {
      # Chrome (with google)
      provides.chrome = {
        name = "networking/chrome";
        provides.to-users = {
          user,
          host,
        }: {
          name = "networking/chrome(${user.userName}@${host.name})";
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.chrome-settings
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.chrome-settings
            ];
          };
        };
      };
      # Chromium (sans google)
      provides.chromium = {
        name = "networking/chromium";
        provides.to-users = {
          user,
          host,
        }: {
          name = "networking/chromium(${user.userName}@${host.name})";
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.chromium-settings
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.chromium-settings
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Google chrome
    darwin = {
      chrome-settings = {...}: {
        key = "chrome-settings#darwin";
        config = {
          homebrew.casks = ["google-chrome"];
        };
      };
      chromium-settings = {...}: {
        key = "chromium-settings#darwin";
        config = {
          homebrew.casks = ["ungoogled-chromium"];
        };
      };
    };
    homeManager = {
      chrome-settings = {
        pkgs,
        lib,
        ...
      }: {
        key = "chrome-settings#homeManager";
        config = {
          home.packages = with pkgs; (
            []
            + (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              google-chrome
            ])
          );
        };
      };
      chromium-settings = {pkgs, ...}: {
        key = "chromium-settings#homeManager";
        config = {
          programs.chromium = {
            enable = true;
            package =
              if pkgs.stdenv.hostPlatform.isLinux
              then pkgs.ungoogled-chromium
              else null;
          };
        };
      };
    };
  };
}

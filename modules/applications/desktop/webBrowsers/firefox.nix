# Firefox setup in den
{
  inputs,
  flib,
  ...
}: {
  # Hook up firefox to den
  den = {
    aspects.desktop = {
      provides.webbrowser = {
        provides.firefox = {
          name = "desktop/webbrowser/firefox";
          # Just dispatch aspect to the user scope
          provides.to-users = {
            host,
            user,
          }: {
            # Collission protection
            name = "desktop/webbrowser/firefox(${user.userName}@${host.name})";
            # Dispatch the darwin module
            darwin = {...}: {
              imports = [
                inputs.self.modules.darwin.firefox-settings
              ];
            };
            # Dispatch the home manager modules
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.firefox-settings
              ];
            };
            # Establish theming
            stylix = {lib, ...}: {
              targets.firefox = {
                # Can only enable when profiles are non-empty
                enable = lib.mkOptionDefault false;
                # Need this to set the colors
                colorTheme.enable = true;
                # This breaks some stuff
                firefoxGnomeTheme.enable = false;
              };
            };
          };
        };
      };
    };
  };

  # Firefox setting module
  flake.modules = {
    darwin.firefox-settings = {...}: {
      key = "firefox-settings#darwin";
      config = {
        # homebrew.casks = [ "firefox" ];
      };
    };

    homeManager.firefox-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "firefox-settings#homeManager";
      config = lib.mkMerge [
        {
          programs.firefox = {
            enable = true;
            package =
              if pkgs.stdenv.hostPlatform.isLinux
              then pkgs.firefox
              else if pkgs.stdenv.hostPlatform.isDarwin
              then pkgs.firefox
              else null;
          };
        }
      ];
    };
  };
}

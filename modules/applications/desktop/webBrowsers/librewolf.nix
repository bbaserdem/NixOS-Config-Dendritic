# LibreWolf setup in den
{
  inputs,
  flib,
  ...
}: {
  # Hook up librewolf to den
  den = {
    aspects.desktop = {
      provides.webbrowser = {
        provides.librewolf = {
          name = "desktop/webbrowser/librewolf";
          # Just dispatch aspect to the user scope
          provides.to-users = {
            host,
            user,
          }: {
            # Collission protection
            name = "desktop/webbrowser/librewolf(${user.userName}@${host.name})";
            # Dispatch the home manager modules
            darwin = {...}: {
              imports = [
                inputs.self.modules.darwin.librewolf-settings
              ];
            };
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.librewolf-settings
              ];
            };
            # Establish theming
            stylix = {lib, ...}: {
              targets.librewolf = {
                # Can only enable when profiles are non-empty
                enable = lib.mkOptionDefault false;
                # Need this to set the colors
                colorTheme.enable = true;
                # This breaks some stuff actually
                firefoxGnomeTheme.enable = false;
              };
            };
          };
        };
      };
    };
  };

  # LibreWolf setting module
  flake.modules = {
    darwin.librewolf-settings = {...}: {
      key = "librewolf-settings#darwin";
      config = {
        # homebrew.casks = ["librewolf"];
      };
    };

    homeManager.librewolf-settings = {pkgs, ...}: {
      key = "librewolf-settings#homeManager";
      config = {
        programs.librewolf = {
          enable = true;
          package =
            if pkgs.stdenv.hostPlatform.isLinux
            then pkgs.librewolf
            else if pkgs.stdenv.hostPlatform.isDarwin
            then pkgs.librewolf
            else null;
        };
      };
    };
  };
}

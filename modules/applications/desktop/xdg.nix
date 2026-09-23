# XDG setup
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.desktop = {
      # Load xdg by default
      includes = [
        den.aspects.desktop._.xdg
      ];
      provides.xdg = {
        # For standalone home and nixos; turn on the desktop portal in linux
        nixos = {...}: {
          imports = [
            inputs.self.modules.generic.xdg-portal
          ];
        };
        homeManager = {...}: {
          imports = [
            inputs.self.modules.generic.xdg-portal
          ];
        };
        # User dispatch
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/xdg(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.xdg-settings
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Nixos system-wide xdg portal settings
    generic.xdg-portal = {
      pkgs,
      lib,
      ...
    }: {
      key = "xdg-portal#generic";
      # Linux guard for when used in home-manager
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
        };
      };
    };
    # Home-Manager configuration
    homeManager.xdg-settings = {
      lib,
      pkgs,
      ...
    }: {
      key = "xdg-settings#nixos";
      config = lib.mkMerge [
        {
          # Enable XDG specification
          xdg = {
            enable = true;
          };
          home.preferXdgDirectories = true;
        }
        ( # Linux only options
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            # Linux-only functionality
            xdg = {
              # User directory specification
              userDirs = {
                enable = true;
                createDirectories = true;
              };

              # Autostart in linux
              autostart = {
                enable = true;
                readOnly = true;
              };

              # Mime type associations in linux
              mime = {
                enable = true;
              };
              mimeApps = {
                enable = true;
              };

              # Default terminal open specification
              terminal-exec = {
                enable = true;
              };

              # Default to false; since only needs enables in non-standalone
              portal = lib.mkOverride 1100 {
                enable = false;
              };
            };
          }
        )
      ];
    };
  };
}

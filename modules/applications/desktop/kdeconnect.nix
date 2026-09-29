# KDE connect implementation; both for plasma and gnome
{inputs, ...}: {
  den = {
    aspects.desktop = {
      provides.kdeconnect = {
        name = "desktop/kdeconnect";
        # System module config for nixos
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.kdeconnect-settings
          ];
        };
        # Open the required ports through our quirk
        local-ports = [
          {
            proto = "all";
            from = 1714;
            to = 1764;
          }
        ];

        # User-level; dispatch the enable config to users
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/kdeconnect(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.kdeconnect-settings
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    nixos.kdeconnect-settings = {
      config,
      lib,
      pkgs,
      ...
    }: {
      key = "kdeconnect-settings#nixos";
      config = lib.mkMerge [
        {
          # Enable kdeconnect
          programs.kdeconnect = {
            enable = true;
          };
        }
        ( # If there is gnome, and no plasma, we will switch to gsconnect
          lib.mkIf (
            (! config.services.desktopManager.plasma6.enable)
            && (config.services.desktopManager.gnome.enable)
          ) {
            programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
          }
        )
      ];
    };

    # Home-Manager settings
    homeManager.kdeconnect-settings = {
      lib,
      pkgs,
      ...
    } @ args: {
      key = "kdeconnect-settings#homeManager";
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (lib.mkMerge [
        {
          # Base enable the kdeconnect daemon for the desktop
          services.kdeconnect = {
            enable = true;
            indicator = true;
          };
        }
        ( # If we detect the system has gnome and no kde; we set up for gnome
          lib.optionalAttrs (args ? osConfig) (
            lib.mkIf (
              (! args.osConfig.services.desktopManager.plasma6.enable)
              && (args.osConfig.services.desktopManager.gnome.enable)
            ) {
              # Turn off the kdeconnect module; wont be using kdeconnect binary
              services.kdeconnect = {
                enable = lib.mkOverride 500 false;
                indicator = lib.mkOverride 500 false;
              };
              # Add gsconnect to gnome extensions
              programs.gnome-shell.extensions = [
                {package = pkgs.gnomeExtensions.gsconnect;}
              ];
            }
          )
        )
      ]);
    };
  };
}

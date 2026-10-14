# GUI toolkit settings
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.desktop = {
      # Auto include us
      includes = [
        den.aspects.desktop._.gtk
        den.aspects.desktop._.qt
      ];
      provides.to-users.includes = [
        den.aspects.desktop._.gtk._.to-users
        den.aspects.desktop._.qt._.to-users
      ];

      # GTK dispatch
      provides.gtk = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/gtk(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.desktop-gtk
            ];
          };
          stylix = {
            pkgs,
            lib,
            ...
          }:
            lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
              targets.gtk = {
                enable = true;
                flatpakSupport.enable = true;
              };
            };
        };
      };

      # QT dispatch
      provides.qt = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/qt(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.desktop-qt
            ];
          };
          stylix = {
            pkgs,
            lib,
            ...
          }:
            lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
              targets.qt = {
                # Soft default to true; plasma inclusion will set this false
                # (Stylix qt breaks plasma)
                enable = true;
                platform = "qtct";
                standardDialogs = "default";
              };
            };
        };
      };
    };
  };

  # Modules
  flake.modules.homeManager = {
    # GTK
    desktop-gtk = {
      lib,
      pkgs,
      ...
    }: {
      key = "desktop-gtk#homeManager";
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        # Actually nothing needed
      };
    };
    # QT
    desktop-qt = {
      lib,
      pkgs,
      ...
    }: {
      key = "desktop-qt#homeManager";
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = with pkgs; [
          kdePackages.qt6ct
          kdePackages.breeze
        ];
      };
    };
  };
}

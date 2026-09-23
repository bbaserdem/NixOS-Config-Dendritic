# GUI toolkit settings
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.desktop = {
      includes = [
        den.aspects.desktop._.gtk
        den.aspects.desktop._.qt
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
          stylix = {lib, ...}: {
            targets.qt = {
              # Soft default to true; plasma inclusion will set this false
              # (Stylix qt breaks plasma)
              enable = lib.mkOverride 1400 true;
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
      key = "desktop-gtk#homeManager";
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = with pkgs; [
          kdePackages.qt6ct
          kdePackages.breeze
        ];
      };
    };
  };
}

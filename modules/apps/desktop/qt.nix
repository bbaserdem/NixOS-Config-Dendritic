# QT styling
{...}: {
  flake.modules = {
    homeManager = {
      # Stylix method of theming qt
      stylix = {
        lib,
        pkgs,
        ...
      }: {
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          stylix.targets = {
            qt = {
              enable = true;
              platform = "qtct";
              standardDialogs = "default";
            };
          };
        };
      };
      qt = {
        lib,
        pkgs,
        ...
      }: {
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          home.packages = with pkgs; [
            kdePackages.qt6ct
            kdePackages.breeze
          ];
        };
      };
    };
  };
}

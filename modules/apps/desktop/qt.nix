# QT styling
{...}: {
  flake.modules = {
    homeManager = {
      # Stylix method of theming qt
      stylix = {
        config,
        lib,
        pkgs,
        ...
      } @ args: {
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
          lib.mkMerge [
            {
              stylix.targets = {
                qt = {
                  # This is defaulting to standalone home-manager
                  enable = lib.mkOverride 1400 true;
                  platform = "qtct";
                  standardDialogs = "default";
                };
              };
            }
            (
              # Stylix QT breaks plasma;
              lib.optionalAttrs (lib.hasAttrByPath ["osConfig"] args) (
                lib.mkMerge [
                  (
                    lib.mkIf (args.osConfig.services.desktopManager.plasma6.enable == true) {
                      stylix.targets.qt.enable = false;
                    }
                  )
                  (
                    lib.mkIf (args.osConfig.services.desktopManager.plasma6.enable != true) {
                      stylix.targets.qt.enable = true;
                    }
                  )
                ]
              )
            )
          ]
        );
      };

      # QT Individual module
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

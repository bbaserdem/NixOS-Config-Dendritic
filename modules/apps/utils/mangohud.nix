# Mangohud; performance measurer
{inputs, ...}: {
  flake.modules = {
    homeManager = {
      # Enable stylix theming for mangohud
      stylix = {...}: {
        stylix.targets.mangohud.enable = true;
      };

      # Enable in home-manager
      mangohud = {
        pkgs,
        lib,
        ...
      }: {
        config = lib.mkMerge [
          {
          }
          (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            programs.mangohud = {
              enable = true;
              enableSessionWide = false;
            };
          })
        ];
      };
    };
  };
}

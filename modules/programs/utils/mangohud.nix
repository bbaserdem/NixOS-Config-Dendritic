# Mangohud; performance measurer
{inputs, ...}: {
  flake.modules = {
    # Include to system
    generic.mangohud = {...}: {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.btop
      ];
    };
    nixos.mangohud = inputs.self.modules.generic.mangohud;
    darwin.mangohud = inputs.self.modules.generic.mangohud;

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

# GTK styling
{...}: {
  flake.modules = {
    homeManager = {
      # Stylix method of theming gtk
      stylix = {
        lib,
        pkgs,
        ...
      }: {
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          stylix.targets = {
            gtk = {
              enable = true;
              flatpakSupport.enable = true;
            };
          };
        };
      };

      # Configuring GTK settings (bare for now)
      gtk = {
        lib,
        pkgs,
        ...
      }: {
        config =
          lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          };
      };
    };
  };
}

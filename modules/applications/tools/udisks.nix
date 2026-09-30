# Udisks management in nixos
{...}: {
  flake.modules = {
    nixos.disks-settings = {...}: {
      key = "disks-settings#nixos";
      config = {
        services.udisks2 = {
          enable = true;
        };
      };
    };
    homeManager.disks-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "disks-settings#homeManager";
      config = lib.mkMerge [
        (
          lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
            services.udiskie = {
              enable = true;
              tray = "always";
              notify = true;
              automount = false;
            };
          }
        )
      ];
    };
    homeManager.disks-gui = {
      pkgs,
      lib,
      ...
    }: {
      key = "disks-gui#homeManager";
      config = {
        home.packages = with pkgs; (
          [
          ]
          ++ (
            # Linux-only
            lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              baobab
            ]
          )
        );
      };
    };
  };
}

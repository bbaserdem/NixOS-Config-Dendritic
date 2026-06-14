# Enabling udisks service
{...}: {
  flake.modules = {
    # Enable systemwide
    nixos.udisks = {...}: {
      services.udisks2.enable = true;
    };

    # Enable frontend in userspace
    homeManager.udisks = {
      pkgs,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
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
  };
}

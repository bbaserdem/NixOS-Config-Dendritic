# Hyprland userspace utilities
{...}: {
  flake.modules.homeManager.hyprland = {
    lib,
    pkgs,
    config,
    ...
  }: {
    config = lib.mkMerge [
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # Screenshot utility
          hyprshot = {
            enable = true;
            saveLocation = "${config.xdg.userDirs.pictures}/Screenshots/${config.networking.hostName}/";
          };
        }
      )
    ];
  };
}

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
          programs.hyprshot = {
            enable = true;
            saveLocation = lib.mkOverride 1400 "${config.xdg.userDirs.pictures}/Screenshots/${config.networking.hostName}/";
          };
        }
      )
    ];
  };
}

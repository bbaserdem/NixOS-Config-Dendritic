# Hyprland userspace utilities
{...}: {
  flake.modules.homeManager.hyprland = {
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkMerge [
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.packages = with pkgs; [
            playerctl
            brightnessctl
            poweralertd
            pavucontrol
            runapp
          ];
        }
      )
    ];
  };
}

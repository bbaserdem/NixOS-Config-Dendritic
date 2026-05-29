# Hyprland plugins
{...}: {
  flake.modules.homeManager.wolframite = {
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkMerge [
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # Hyprsplit; make hyprland work like bspwm
          wayland.windowManager.hyprland = {
            plugins = [
              pkgs.hyprlandPlugins.hyprsplit
            ];
            settings = {
              plugin.hyprsplit = {
                num_workspaces = 10;
                persistent_workspaces = true;
              };
            };
          };
        }
      )
    ];
  };
}

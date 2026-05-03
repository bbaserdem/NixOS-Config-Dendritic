# Hyprland setup
{...}: {
  flake.modules = {
    # Home manager
    homeManager = {
      stylix = {...}: {
        # Enable hyprpaper wallpaper daemon
        stylix.targets.hyprpaper = {
          enable = true;
          image.enable = true;
        };
      };
      hyprland = {
        lib,
        pkgs,
        ...
      }: {
        config = lib.mkMerge [
          (
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              # Inhibit power button in favor of management
              wayland.windowManager.hyprland.settings.exec-once = [
                "systemd-inhibit --what=handle-power-key --who=hyprland --why='Handled by Hyprland keybinds' --mode=block sleep infinity"
              ];

              # Idle daemon
              services.hypridle = {
                enable = true;
                services.hypridle.systemdTarget = "wayland-session@Hyprland.target";
              };

              # Wallpaper setup
              services.hyprpaper = {
                enable = true;
              };
              # Make hyprpaper unit auto-load on UWSM hyprland
              systemd.user.services.hyprpaper = {
                Install.WantedBy = lib.mkForce ["wayland-session@Hyprland.target"];
                Unit = {
                  After = lib.mkForce ["wayland-session@Hyprland.target"];
                  PartOf = lib.mkForce ["wayland-session@Hyprland.target"];
                };
              };
              # Hyprdynamicmonitors, no settings here; look at monitors for the settings
              home.hyprdynamicmonitors = {
                enable = true;
                systemdTarget = "wayland-session@Hyprland.target";
              };
            }
          )
        ];
      };
    };
  };
}

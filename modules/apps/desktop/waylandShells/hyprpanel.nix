# Hyprpanel, desktop shell
{...}: {
  flake.modules.homeManager = {
    stylix = {...}: {
      # Enable stylix theming
      stylix.targets = {
        hyprpanel = {
          enable = true;
          colors.enable = true;
          fonts.enable = true;
        };
        hyprlock = {
          enable = true;
          colors.enable = true;
          image.enable = true;
          useWallpaper = true;
        };
      };
    };

    # Hyprpanel module
    waylandShell = {
      lib,
      pkgs,
      config,
      ...
    }: {
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (
        lib.mkMerge [
          {
            # Here would go non-startup settings
            programs = {
              hyprpanel.enable = true;
              # Enable hyprlock, the lock command backend
              hyprlock.enable = true;
            };
          }
          (
            lib.mkIf (config.local.waylandShell.default == "hyprpanel") {
              # Set auto-start
              programs.hyprpanel.systemd.enable = true;
              # Override systemd unit to only auto-launch in uwsm targets
              systemd.user.services.hyprpanel = {
                Install.WantedBy = lib.mkForce [
                  "wayland-session@Hyprland.target"
                ];
                Unit = {
                  After = lib.mkForce [
                    "wayland-session@Hyprland.target"
                  ];
                  PartOf = lib.mkForce [
                    "wayland-session@Hyprland.target"
                    "tray.target"
                  ];
                };
              };
              # Hyprland integration
              # Power menu
              wayland.windowManager.hyprland.settings.bindl = [
                ", XF86PowerOff, exec, ${config.programs.hyprpanel.package}/bin/hyprpanel toggleWindow powerdropdownmenu"
              ];
              # Register hyprlock as the lock command
              services.hypridle.settings.general.lock_cmd = "${config.programs.hyprlock.package}/bin/hyprlock";
            }
          )
        ]
      );
    };
  };
}

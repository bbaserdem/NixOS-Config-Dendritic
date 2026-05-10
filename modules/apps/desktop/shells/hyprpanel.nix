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
    hyprpanel = {
      lib,
      pkgs,
      config,
      ...
    }: {
      config = lib.mkIf ((pkgs.stdenv.hostPlatform.isLinux) && (config.local.waylandShell == "hyprpanel")) (let
        hyprpanel = "${config.programs.hyprpanel.package}/bin/hyprpanel";
      in {
        programs = {
          # Enable hyprpanel
          hyprpanel = {
            enable = true;
            systemd.enable = true;
          };
          # Enable hyprlock, the lock command backend
          hyprlock = {
            enable = true;
          };
        };
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

        # Hyprland integration
        # Power menu
        wayland.windowManager.hyprland.settings.bindl = [
          ", XF86PowerOff, exec, ${hyprpanel} toggleWindow powerdropdownmenu"
        ];
        # Register hyprlock as the lock command
        services.hypridle.settings.general.lock_cmd = "${config.programs.hyprlock.package}/bin/hyprlock";
      });
    };
  };
}

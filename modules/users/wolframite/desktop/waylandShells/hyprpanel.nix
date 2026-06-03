# Hyprpanel configuration
{...}: {
  flake.modules.homeManager.wolframite = {
    lib,
    pkgs,
    config,
    ...
  }: {
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (let
      # TODO: configure to use runapp instead of uwsm app, after 26.05 release
      xdg-open = "${pkgs.xdg-utils}/bin/xdg-open";
      runapp = "${pkgs.runapp}/bin/runapp";
      uwsm = "${pkgs.uwsm}/bin/uwsm";
      kitty = "${config.programs.kitty.package}/bin/kitty";
    in {
      programs.hyprpanel.settings = {
        theme = {
          font = {
            name = "Unifont";
            label = "Unifont";
            size = "1.0rem";
            weight = 500;
          };
          bar = {
            menus = {
              enableShadow = false;
              shadowMargins = "5px 5px";
            };
            floating = true;
            buttons = {
              enableBorders = true;
              borderSize = "0.05em";
              y_margins = "0.2em";
            };
            border = {
              location = "none";
              width = "0.1em";
            };
            enableShadow = true;
            margin_sides = "0.5em";
            outer_spacing = "0em";
          };
          notification.enableShadow = true;
          osd = {
            enable = true;
            orientation = "horizontal";
            location = "top";
            enableShadow = true;
          };
        };
        menus = {
          transition = "crossfade";
          media = {
            hideAuthor = false;
            displayTime = true;
            displayTimeTooltip = true;
          };
          clock = {
            weather.unit = "metric";
            time = {
              military = true;
              hideSeconds = true;
            };
          };
          dashboard = {
            stats.enable_gpu = true;
            directories = {
              right = {
                directory1.command = "${runapp} ${xdg-open} ${config.xdg.userDirs.documents}";
                directory2.command = "${runapp} ${xdg-open} ${config.xdg.userDirs.pictures}";
              };
              left = {
                # TODO: Adapt to new projects dir in 26.05
                directory3.command = "${runapp} ${xdg-open} ${config.xdg.userDirs.projects}";
                directory2.command = "${runapp} ${xdg-open} ${config.xdg.userDirs.videos}";
                directory1.command = "${runapp} ${xdg-open} ${config.xdg.userDirs.download}";
              };
            };
          };
          power = {
            lowBatteryNotification = true;
            logout = "${uwsm} exit";
          };
        };
        tear = false;
        scalingPriority = "hyprland";
        bar = {
          layouts = {
            "*" = {
              left = [
                "dashboard"
                "workspaces"
                "cpu"
                "ram"
                "cputemp"
                "storage"
              ];
              middle = [
                "clock"
                "media"
              ];
              right = [
                "systray"
                "volume"
                "microphone"
                "bluetooth"
                "network"
                "notifications"
                "hypridle"
                "battery"
                "power"
              ];
            };
          };
          customModules = {
            ram.label = true;
            storage = {
              paths = ["/"];
              label = true;
              labelType = "percentage";
              round = true;
            };
            weather.unit = "metric";
            worldclock.format = "%H:%M:%S %p %Z";
          };
        };
        terminal = kitty;
        notifications.showActionsOnHover = true;
      };
    });
  };
}

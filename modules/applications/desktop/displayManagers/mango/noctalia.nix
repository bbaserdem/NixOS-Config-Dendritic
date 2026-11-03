# Noctalia shell for mango
{inputs, ...}: {
  # Modules
  flake.modules = {
    nixos.mango-noctalia = {...}: {
      key = "mango-noctalia#nixos";
      imports = with inputs.self.modules.nixos; [
        noctalia
      ];
      config = {
        # Set noctalia to launch in mango with systemd user service
        programs.noctalia.systemd = {
          enable = true;
          target = "wayland-session@mango.target";
        };
      };
    };
    homeManager.mango-noctalia = {
      config,
      options,
      lib,
      ...
    }: {
      key = "mango-noctalia#homeManager";
      imports = with inputs.self.modules.homeManager; [
        noctalia
      ];
      config =
        lib.optionalAttrs
        (lib.hasAttrByPath ["wayland" "windowManager" "mango"] options)
        {
          programs.noctalia.settings = {
            # Noctalia setup for mango

            # Wallpaper
            wallpaper = {
              directory = "${config.xdg.userDirs.pictures}/Wallpapers";
              automation = {
                enabled = true;
                interval_seconds = 900;
                recursive = true;
              };
            };

            # Shell settings
            shell = {
              # Screenshot
              screenshot = {
                directory = "${config.xdg.userDirs.pictures}/Screenshots/";
                format = "png";
                quality = 100;
                copy_to_clipboard = true;
                save_to_file = true;
                remember_last_region = true;
                show_region_dimensions = true;
              };
              # Panel
              panel = {
                control_center_placement = "floating";
                floating_layer = "top";
                list_item_background = true;
                open_near_click_wallpaper = true;
                shadow = false;
                transparency_mode = "glass";
              };
              # Launcher
              launcher = {
                auto_paste = "shift_insert";
                category_icons_only = true;
                default_view = "pinned";
                show_app_actions = true;
                track_usage = false;
              };
            };

            # OSD settings
            osd = {
              orientation = "vertical";
              position = "bottom_center";
              position_vertical = "center_right";
            };

            # Hot-corners
            hot_corners = {};
          };
        };
    };
  };
}

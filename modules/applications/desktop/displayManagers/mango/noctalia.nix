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
          wayland.windowManager.mango = {
            bottomPrefixes = ["source"];
            settings.source_optional = "${config.xdg.configHome}/mango/noctalia.conf";
          };
          programs.noctalia.settings = {
            # Noctalia setup for mango

            # Theme settings
            theme = {
              # TODO: Remove when stylix updates to 26.11
              source = lib.mkDefault "wallpaper";
              wallpaper_scheme = "vibrant";
              templates = {
                enable_builtin_templates = true;
                builtin_ids = [
                  "mango"
                  "ghostty"
                  "kitty"
                ];
                enable_community_templates = true;
                community_ids = [
                ];
              };
            };

            # Shell settings
            shell = {
              settings_expand_all_groups = true;
              settings_window_translucent = true;
              # Clipboard
              clipboard_enabled = true;
              clipboard_keep_from_closed_apps = true;
              clipboard_history_max_entries = 10;
              clipboard_auto_paste = "shift_insert";
              # Polkit
              polkit_agent = true;
              password_style = "random";
              # Launcher
              launch_apps_as_systemd_services = false;
              launch_apps_custom_command = "runapp $CMD";
              launcher = {
                auto_paste = "shift_insert";
                category_icons_only = true;
                default_view = "pinned";
                show_app_actions = true;
                track_usage = false;
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
              # Screenshot
              screenshot = {
                directory = "${config.xdg.userDirs.pictures}/Screenshots/";
                format = "png";
                quality = 100;
                copy_to_clipboard = true;
                save_to_file = true;
                remember_last_region = true;
                show_region_dimensions = true;
                confirm_region = true;
              };
              # Window switcher
              window_switcher = {
                style = "carousel";
                mru = false;
                show_caption = true;
                show_count = true;
                show_app_icon = true;
                show_all_outputs = true;
                current_workspace_only = false;
              };
            };

            # On screen display settings
            osd = {
              orientation = "vertical";
              position = "bottom_center";
              position_vertical = "center_right";
            };

            # Wallpaper
            wallpaper = {
              directory = "${config.xdg.userDirs.pictures}/Wallpapers";
              automation = {
                enabled = true;
                interval_seconds = 900;
                recursive = true;
              };
            };

            # Hot-corners
            hot_corners = {
              enabled = true;
              top_left.action = "none";
              bottom_left.action = "none";
              bottom_right.action = "window_switcher";
              top_right.action = "none";
            };

            # Application dock
            dock = {
              enabled = true;
              position = "left";
              icon_size = 48;
              item_spacing = 6;
              compositor_blur = true;
              border = "outline_variant";
              border_width = 0.0; # inside outline width in pixels; 0 disables it
              radius = 16;
              concave_edge_corners = true; # carve the screen-edge corners inward; requires margin_edge = 0
              # Behavior
              show_running = true;
              auto_hide = true;
              smart_auto_hide = true;
              reserve_space = false;
              layer = "top";
              # Scaling
              active_scale = 1.0;
              inactive_scale = 0.85;
              magnification = true;
              magnification_scale = 1.45;
              show_instance_count = false;
              show_dots = true;
              # Launcher
              launcher_position = "none";
              # App-pinning
              # pinned = ["firefox" "code" "kitty"];
              # Color and theme related settings
              background_opacity = 0.88;
              shadow = false; # cast the global [shell.shadow]
              active_opacity = 1.0;
              inactive_opacity = 0.85;
            };

            # Lock screen
            lockscreen = {
              grace_period_seconds = 5;
            };
            # Widgets are established in mango den
            lockscreen_widgets = {
              enabled = true;
              schema_version = 2;
              grid = {
                cell_size = 16;
                major_interval = 4;
                visible = true;
              };
            };
            # Idle behavior
            idle = {
              behavior_order = ["screen-off" "lock" "suspend"];
              pre_action_fade_seconds = 5.0;
              behavior = {
                screen-off = {
                  timeout = 590;
                  action = "screen_off";
                  enabled = true;
                };
                lock = {
                  timeout = 600;
                  action = "lock";
                  enabled = true;
                };
                suspend = {
                  timeout = 900;
                  action = "lock_and_suspend";
                  enabled = true;
                };
              };
            };

            # Main bar
            widget = {
              mid_spacer.type = "spacer";
              left_spacer.type = "spacer";
            };
            bar.default = {
              margin_ends = 0;
              radius_top_left = 0;
              radius_top_right = 0;
              background_opacity = 0.8;
              scale = 1.35;
              shadow = false;
              contact_shadow = false;
              thickness = 48;
              start = [
                "workspaces"
                "left_spacer"
                "cpu"
                "ram"
                "temp"
              ];
              center = [
                "group:time"
                "mid_spacer"
                "media"
              ];
              end = [
                "tray"
                "network"
                "clipboard"
                "bluetooth"
                "caffeine"
                "brightness"
                "volume"
                "notifications"
                "battery"
                "session"
              ];
              capsule_group = [
                {
                  id = "time";
                  accordion = false;
                  accordion_direction = "end";
                  border_width = 1.0;
                  enabled = true;
                  fill = "surface_container";
                  members = ["clock" "date"];
                  opacity = 1.0;
                  padding = 6.0;
                  widget_spacing = 24;
                }
              ];
            };
          };
        };
    };
  };
}

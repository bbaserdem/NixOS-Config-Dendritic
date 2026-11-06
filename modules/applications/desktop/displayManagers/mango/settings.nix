# Mango generic settings
{...}: {
  # Modules
  flake.modules.homeManager.mango-settings = {
    options,
    lib,
    ...
  }: {
    key = "mango-settings#homeManager";
    config =
      lib.optionalAttrs
      (lib.hasAttrByPath ["wayland" "windowManager" "mango"] options)
      {
        wayland.windowManager.mango.settings = {
          # Blur settings
          blur = 1;
          blur_layer = 0;
          blur_optimized = 1;
          blur_params = {
            radius = 5;
            num_passes = 2;
            noise = 0.02;
            brightness = 0.9;
            contrast = 0.9;
            saturation = 1.2;
          };
          # Shadow settings
          shadows = 1;
          layer_shadows = 1;
          shadow_only_floating = 0;
          shadows_size = 10;
          shadows_blur = 15;
          shadows_position = {
            x = 0;
            y = 0;
          };
          # Gaps
          smart_gaps = 0;
          no_border_when_single = 0;
          gap = {
            inner = {
              horizontal = 5;
              vertical = 5;
            };
            outer = {
              horizontal = 10;
              vertical = 10;
            };
          };
          # Borders
          border_px = 4;
          # Scratchpad
          scratchpad = {
            width_ratio = 0.8;
            height_ratio = 0.9;
          };
          # Corner settings
          border_radius = 6;
          no_radius_when_single = 0;
          # Dimming overlay
          dim.enable = 1;
          # Animations
          animations = 1;
          layer_animations = 0;
          tag_animation_direction = 1;
          animation = {
            # Used types
            type = {
              open = "slide";
              close = "fade";
            };
            # Timing
            duration = {
              move = 500;
              open = 400;
              tag = 350;
              close = 500;
              focus = 0;
            };
            # Curve for the animation ramp
            curve = {
              open = "0.46,1.0,0.29,1";
              move = "0.46,1.0,0.29,1";
              tag = "0.46,1.0,0.29,1";
              close = "0.08,0.92,0,1";
              focus = "0.46,1.0,0.29,1";
              opacity = {
                fade_out = "0.5,0.5,0.5,0.5";
                fade_in = "0.46,1.0,0.29,1";
              };
            };
            # Fade
            fade_in = 1;
            fade_out = 1;
          };
          zoom_initial_ratio = 0.4;
          zoom_end_ratio = 0.8;
          # Hot area
          enable_hotarea = 1;
          hotarea = {
            size = 10;
            corner = 0;
            disable_on_fullscreen = 1;
          };
          # Overview
          overview = {
            gap = {
              inner = 5;
              outer = 30;
            };
          };
          overcircle = {
            center_ratio = 0.5;
          };
          title.message.bar = {
            height = 52;
            gap = 20;
          };
          # Behavior
          axis_bind_apply_timeout = 100;
          focus_on_activate = 1;
          idle_inhibit = {
            ignore_visible = 0;
            when_fullscreen = 0;
          };
          sloppy_focus = 1;
          warp_cursor = 1;
          focus_cross_monitor = 0;
          focus_direction_only_zone_overlap = 1;
          focus_cross_tag = 0;
          enable_floating_snap = 0;
          snap_distance = 30;
          float_full_to_top = 0;
          cursor_size = 24;
          drag_tile_to_tile = 1;
          drag_tile_small = 1;
          # Input methods
          repeat_rate = 25;
          repeat_delay = 600;
          numlock_on = 0;
          disable_trackpad = 0;
          tap_to_click = 1;
          tap_and_drag = 1;
          drag_lock = 1;
          trackpad = {
            natural_scrolling = 1;
            disable_while_typing = 1;
            left_handed = 0;
            middle_button_emulation = 0;
          };
          swipe_min_threshold = 1;
          mouse_natural_scrolling = 1;
        };
      };
  };
}

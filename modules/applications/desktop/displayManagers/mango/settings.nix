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
          blur_layer = 1;
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
          # Corner settings
          border_radius = 6;
          no_radius_when_single = 0;
          # Dimming overlay
          dim.enable = 1;
          # Animations
          animatios = 1;
          layer_animations = 1;
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
        };
      };
  };
}

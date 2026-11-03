# Mango color settings (concentrate here so maybe integrate to stylix?)
{...}: {
  # Modules
  flake.modules.homeManager.mango-colors = {
    options,
    lib,
    ...
  }: {
    key = "mango-colors#homeManager";
    config =
      lib.optionalAttrs
      (lib.hasAttrByPath ["wayland" "windowManager" "mango"] options)
      {
        wayland.windowManager.mango.settings = {
          # Blur settings
          shadows_color = "0x000000ff";
          # Dim settings
          dim = {
            focused_color = "0x00000000";
            unfocused_color = "0x00000022";
          };
          # General appearance; colors
          root_color = "0x201b14ff";
          border_color = "0x444444ff";
          drop_color = "0x8FBA7C55";
          split_color = "0xEB441EFF";
          focus_color = "0xc9b890ff";
          maximized_screen_color = "0x89aa61ff";
          urgent_color = "0xad401fff";
          scratchpad_color = "0x516c93ff";
          global_color = "0xb153a7ff";
          overlay_color = "0x14a57cff";
          # Window opacity settings
          focused_opacity = 1.0;
          unfocused_opacity = 1.0;
          # Fade animation opacity
          fade_in_begin_opacity = 0.0;
          fade_out_begin_opacity = 1.0;
        };
      };
  };
}

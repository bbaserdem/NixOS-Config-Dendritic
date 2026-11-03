# Mango layout settings
{...}: {
  # Modules
  flake.modules.homeManager.mango-layout = {
    options,
    lib,
    ...
  }: {
    key = "mango-layout#homeManager";
    config =
      lib.optionalAttrs
      (lib.hasAttrByPath ["wayland" "windowManager" "mango"] options)
      {
        wayland.windowManager.mango.settings = {
          # Tag settings
          # We have 9 tags by default
          tag_num = 9;
          # Don't close empty tags
          tag_gather = 0;
          # Layouts for each tag, some hardcoded but they default to fair.
          tag_rule =
            [
              "id:1,layout_name:scroller"
              "id:2,layout_name:dwindle"
              "id:8,layout_name:deck"
              "id:9,layout_name:monocle"
            ]
            ++ (
              (lib.range 3 7)
              |> lib.map builtins.toString
              |> lib.map (i: "id:${i},layout_name:fair")
            );

          # Layout settings
          circle_layout = "dwindle,scroller,monocle,fair,center_tile,deck";
          # Master-stack layout
          new_is_master = 1;
          default.master = {
            factor = 0.6;
            count = 1;
          };
          # Scroller layout (niri-like)
          scroller = {
            structs = 20;
            focus_center = 1;
            prefer_center = 0;
            prefer_overspread = 1;
            proportion_preset = "0.5,0.8,1.0";
            default = {
              proportion = 0.8;
              proportion_single = 1.0;
            };
          };
          edge.scroller = {
            pointer_focus = 1;
            focus_allow_speed = 0.0;
          };
          # Dwindle layout (bspwm like)
          dwindle = {
            smart = {
              resize = 1;
              split = 1;
            };
            split.ratio = 0.5;
            drop_simple_split = 1;
            manual_split = 0;
            horizontal_split = 1;
            vertical_split = 1;
            preserve_split = 0;
          };
          # Monocle layout (i3 tabs like)
          monocle = {
            tab.mode = 1;
            no_border = 0;
            no_gap = 1;
          };
          # Deck layout
          deck = {
            tab.mode = 1;
          };
        };
      };
  };
}

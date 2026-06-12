# Yazi plugin keymap
{...}: {
  flake.wrappers.yazi = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        settings.keymap.mgr.prepend_keymap = [
          # Smart stuff
          {
            on = "l";
            run = "plugin smart-enter";
            desc = "Enter directory or open file";
          }
          {
            on = "p";
            run = "plugin smart-paste";
            desc = "Paste into hovered directory or CWD";
          }
          # Mounting
          {
            on = "M";
            run = "plugin mount";
            desc = "Open mount manager";
          }
          # Split tabs
          {
            on = ["\\" "\\"];
            run = "plugin split-tabs spl_toggle";
            desc = "Toggle split tabs";
          }
          {
            on = ["\\" "<Tab>"];
            run = "plugin split-tabs spl_switch_tab";
            desc = "Switch split tab focus";
          }
          {
            on = ["\\" "p"];
            run = "plugin split-tabs spl_preview";
            desc = "Toggle split preview";
          }
          # Projects
          {
            on = ["g" "p" "s"];
            run = "plugin projects save";
            desc = "Save current project";
          }
          {
            on = ["g" "p" "l"];
            run = "plugin projects load";
            desc = "Load project";
          }
          {
            on = ["g" "p" "p"];
            run = "plugin projects load_last";
            desc = "Load last project";
          }
          {
            on = ["g" "p" "d"];
            run = "plugin projects delete";
            desc = "Delete project";
          }
        ];
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          settings.keymap.mgr.prepend_keymap = [
            {
              on = ["b" "a"];
              run = "plugin mactag add";
              desc = "Tag selected files";
            }
            {
              on = ["b" "r"];
              run = "plugin mactag remove";
              desc = "Untag selected files";
            }
          ];
        }
      )
    ];
  };
}

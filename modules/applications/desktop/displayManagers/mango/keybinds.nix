# Mango keybinds
{...}: {
  # Modules
  flake.modules.homeManager.mango-keybinds = {
    options,
    lib,
    pkgs,
    ...
  }: {
    key = "mango-keybinds#homeManager";
    config =
      lib.optionalAttrs
      (lib.hasAttrByPath ["wayland" "windowManager" "mango"] options)
      {
        wayland.windowManager.mango.settings = {
          # Inhibit power button
          exec_once = [
            (
              "${pkgs.systemd}/bin/systemd-inhibit"
              + " --what=handle-power-key"
              + " --who=mango"
              + " --why=Noctalia-power-menu"
              + " --mode=block"
              + " ${pkgs.coreutils}/bin/sleep infinity"
            )
          ];
          # Media keys (bindl for these so that they work universally)
          bindl = [
            "NONE,XF86AudioMute,spawn,noctalia msg volume-mute"
            "NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down"
            "NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up"
            "NONE,XF86AudioPrev,spawn,noctalia msg media previous"
            "NONE,XF86AudioPlay,spawn,noctalia msg media toggle"
            "NONE,XF86AudioNext,spawn,noctalia msg media next"
            "NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down"
            "NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up"
          ];
          # Regular binds
          bind =
            # Mango environment management
            [
              # Reload
              "SUPER+ALT,Escape,reload_config"
              # Quit mango
              "SUPER+CTRL+ALT,Escape,quit"
            ]
            # Noctalia utilities
            ++ [
              # Control center and settings
              "SUPER+CTRL,Escape,spawn,noctalia msg panel-toggle control-center"
              "SUPER+CTRL+SHIFT,Escape,spawn,noctalia msg settings-toggle"
              # Power setting
              "NONE,XF86PowerOff,spawn,noctalia msg panel-toggle session"
              # Screen lock
              "SUPER,Escape,spawn,noctalia msg session lock"
              # Session menu
              "SUPER+SHIFT,Escape,spawn,noctalia msg panel-toggle session"
              # Launcher
              "SUPER,space,spawn,noctalia msg panel-toggle launcher"
              # Clipboard
              "SUPER,v,spawn,noctalia msg panel-toggle clipboard"
              # Screenshot
              "NONE,Print,spawn,noctalia msg screenshot-fullscreen pick"
              "CTRL,Print,spawn,noctalia msg screenshot-fullscreen all"
              "ALT,Print,spawn,noctalia msg screenshot-region"
              # Wallpaper switch
              "SUPER,c,spawn,noctalia msg wallpaper-random"
            ]
            # Other launchers
            ++ [
              "SUPER,Return,spawn,runapp kitty"
            ]
            # Window management
            ++ [
              # Close window
              "SUPER,q,smartkillclient,"
              "SUPER+SHIFT,q,killclient,force"
              # Switch focus
              "SUPER,Tab,focusstack,next"
              "SUPER+SHIFT,Tab,focusstack,prev"
              "SUPER+ALT,Left,focusdir,left"
              "SUPER+ALT,Right,focusdir,right"
              "SUPER+ALT,Up,focusdir,up"
              "SUPER+ALT,Down,focusdir,down"
              # Pin window global
              "SUPER,apostrophe,toggleglobal,"
              # Toggle floating
              "SUPER,backslash,togglefloating,"
              # Fullscreen (alone or together)
              "SUPER,f,togglefullscreen,"
              "SUPER+SHIFT,f,togglemaximizescreen,"
              "SUPER+ALT,f,togglefakefullscreen,"
              # Scratchpad
              "SUPER,i,minimized,"
              "SUPER+SHIFT,i,restore_minimized"
              "SUPER+ALT,i,toggle_scratchpad,"
            ]
            # Overview mode (some keybinds are without Super key)
            ++ [
              # Use jump mode for current desktop
              "SUPER+ALT,Tab,togglejump,"
              # Use switcher for hold switch behavior; without super
              "ALT,Tab,switcher,next"
              "ALT,Grave,switcher,prev"
              "ALT+SHIFT,Tab,switcher,all_tag_next"
              "ALT+SHIFT,Grave,switcher,all_tag_prev"
              "ALT+CTRL,Tab,switcher,all_next"
              "ALT+CTRL+SHIFT,Grave,switcher,all_prev"
            ]
            # Layout keybinds
            ++ [
              "SUPER,n,switch_layout"
              # Modify master window number
              "SUPER,a,incnmaster,+1"
              "SUPER+SHIFT,a,incnmaster,-1"
              # Monocle, and deck layouts
              "SUPER,m,setlayout,monocle"
              "SUPER+SHIFT,m,setlayout,deck"
              "SUPER+CTRL,m,setlayout,vertical_deck"
              # Tile layouts
              "SUPER,t,setlayout,tile"
              "SUPER+SHIFT,t,setlayout,right_tile"
              "SUPER+ALT,t,setlayout,center_tile"
              "SUPER+CTRL,t,setlayout,vertical_tile"
              # Grid, and fair, layouts
              "SUPER,g,setlayout,fair"
              "SUPER+ALT,g,setlayout,grid"
              "SUPER+CTRL,g,setlayout,vertical_fair"
              "SUPER+CTRL+ALT,g,setlayout,vertical_grid"
              # Dwindle layout (bspwm-like)
              "SUPER,b,setlayout,dwindle"
              # Change split direction
              "SUPER,period,dwindle_toggle_current_split"
              "SUPER+SHIFT,period,dwindle_toggle_split_direction"
              "SUPER+SHIFT,underscore,dwindle_split_horizontal"
              "SUPER+SHIFT,bar,dwindle_split_vertical"
              # Scroller layout (niri-like)
              "SUPER,s,setlayout,scroller"
              "SUPER+CTRL,s,setlayout,vertical_scroller"
              "SUPER+ALT,s,set_proportion,1.0"
              "SUPER+ALT+SHIFT,s,switch_proportion_preset"
              "SUPER+ALT,k,scroller_stack,up"
              "SUPER+ALT,j,scroller_stack,down"
              "SUPER+ALT,h,scroller_stack,left"
              "SUPER+ALT,l,scroller_stack,right"
            ]
            # Tag and monitor management
            ++ [
              # Switch current tag
              "SUPER,Left,viewtoleft,0"
              "SUPER,Up,viewtoleft_have_client,0"
              "SUPER,Right,viewtoright,0"
              "SUPER,Down,viewtoright_have_client,0"
              # Switch monitor focus
              "SUPER+CTRL,Left,focusmon,left"
              "SUPER+CTRL,Right,focusmon,right"
              # Move window inside tag
              "SUPER+SHIFT,Up,move_client,up"
              "SUPER+SHIFT,Down,move_client,down"
              "SUPER+SHIFT,Left,move_client,left"
              "SUPER+SHIFT,Right,move_client,right"
              # Move window to next/prev tag
              "SUPER+SHIFT,p,tagtoleft,0"
              "SUPER+SHIFT,n,tagtoright,0"
              # Move window to next/prev monitor
              "SUPER+CTRL,p,tagmon,left"
              "SUPER+CTRL,n,tagmon,right"
            ]
            ++ ( # Specific tag-binds
              (lib.range 1 9)
              |> builtins.map builtins.toString
              |> builtins.concatMap
              (i: [
                # Focus tag
                "SUPER,${i},view,${i},0"
                # Move to specific tag
                "SUPER+SHIFT,${i},tag,${i},0"
                # Move to specific tag, but don't switch there
                "SUPER+SHIFT+ALT,${i},tagsilent,${i},0"
              ])
            )
            # Desktop effects
            ++ [
              # Gaps
              "SUPER,e,togglegaps"
              "SUPER+ALT,e,incgaps,1"
              "SUPER+ALT+SHIFT,e,incgaps,-1"
              # Resize tiled windows
              "SUPER+CTRL+ALT,Up,resizewin,+0,-50"
              "SUPER+CTRL+ALT,Down,resizewin,+0,+50"
              "SUPER+CTRL+ALT,Left,resizewin,-50,+0"
              "SUPER+CTRL+ALT,Right,resizewin,+50,+0"
              # Floating window movements
              "SUPER+SHIFT+ALT,Up,movewin,+0,-50"
              "SUPER+SHIFT+ALT,Down,movewin,+0,+50"
              "SUPER+SHIFT+ALT,Left,movewin,-50,+0"
              "SUPER+SHIFT+ALT,Right,movewin,+50,+0"
            ];
          # Mouse keybinds
          mousebind = [
            # btn_left and btn_right can't bind none mod key
            "SUPER,btn_left,moveresize,curmove"
            "SUPER,btn_middle,togglemaximizescreen,0"
            "SUPER,btn_right,moveresize,curresize"
          ];
          # Scroll-wheel keybinds
          axisbind = [
            "SUPER,UP,viewtoleft_have_client"
            "SUPER,DOWN,viewtoright_have_client"
          ];
          # Trackpad gesture binds
          gesturebind = [
            # Switch focus around with 3 fingers
            "none,left,3,focusdir,left"
            "none,right,3,focusdir,right"
            "none,up,3,focusdir,up"
            "none,down,3,focusdir,down"
            # Move tag with 4 fingers laterally
            "none,right,4,viewprev_have_client"
            "none,left,4,viewnext_have_client"
            # Open overview with 4 fingers up/down
            "none,up,4,enteroverview"
            "none,down,4,leaveoverview"
          ];
        };
      };
  };
}

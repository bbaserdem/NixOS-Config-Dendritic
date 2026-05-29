# Configuring kitty
{...}: {
  # Flake source; terminal theming
  flake-file.inputs = {
    tinted-terminal = {
      url = "github:tinted-theming/tinted-terminal";
      flake = false;
    };
  };

  flake.modules.homeManager = {
    # Enable stylix theming for kitty
    stylix = {...}: {
      stylix.targets.kitty = {
        enable = true;
        colors.enable = true;
        fonts.enable = true;
        inputs.enable = true;
        opacity.enable = true;
      };
    };

    # Kitty settings
    kitty = {...}: {
      programs.kitty = {
        enable = true;

        # General settings
        settings = {
          disable_ligatures = "cursor";
          background_blur = "8";
          force_ltr = false;
          enable_audio_bell = false;
          cursor_shape = "block";
          cursor_blink_interval = "0.5";
          cursor_stop_blinking_after = 0;
          cursor_trail = 3;
          scrollback_lines = 5000;
          url_style = "curly";
          open_url_with = "default";
          copy_on_select = false;
          tab_separator = " ┇";
          # scrollback_pager = ''${config.home.sessionVariables.EDITOR} -c "set signcolumn=no showtabline=0" -c "silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - "'';
          allow_remote_control = true;
          listen_on = "unix:/tmp/kitty";
          shell_integration = true;
        };

        # Extra config to set
        extraConfig = ''
          # Liberate ctrl+tab
          map ctrl+tab        send_text normal,application \x1b[9;5u
          map ctrl+shift+tab  send_text normal,application \x1b[9;6u

          # Nerd Font override
          # https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points
          # Seti-UI + Custom
          symbol_map U+E5FA-U+E6B7    Symbols Nerd Font Mono
          # Devicons
          symbol_map U+E700-U+E8EF    Symbols Nerd Font Mono
          # Font Awesome
          symbol_map U+ED00-U+F2FF    Symbols Nerd Font Mono
          # Font Awesome Extension
          symbol_map U+E200-U+E2A9    Symbols Nerd Font Mono
          # Material Design Icons
          symbol_map U+F0001-U+F1AF0  Symbols Nerd Font Mono
          # Weather
          symbol_map U+E300-U+E3E3    Symbols Nerd Font Mono
          # Octicons
          symbol_map U+F400-U+F533    Symbols Nerd Font Mono
          symbol_map U+2665           Symbols Nerd Font Mono
          symbol_map U+26A1           Symbols Nerd Font Mono
          # [Powerline Symbols]
          symbol_map U+E0A0-U+E0A2    Symbols Nerd Font Mono
          symbol_map U+E0B0-U+E0B3    Symbols Nerd Font Mono
          # Powerline Extra Symbols
          symbol_map U+E0A3           Symbols Nerd Font Mono
          symbol_map U+E0B4-U+E0C8    Symbols Nerd Font Mono
          symbol_map U+E0CA           Symbols Nerd Font Mono
          symbol_map U+E0CC-U+E0D7    Symbols Nerd Font Mono
          symbol_map U+2630           Symbols Nerd Font Mono
          # IEC Power Symbols
          symbol_map U+23FB-U+23FE    Symbols Nerd Font Mono
          symbol_map U+2B58           Symbols Nerd Font Mono
          # Font Logos (Formerly Font Linux)
          symbol_map U+F300-U+F381    Symbols Nerd Font Mono
          # Pomicons
          symbol_map U+E000-U+E00A    Symbols Nerd Font Mono
          # Codicons
          symbol_map U+EA60-U+EC1E    Symbols Nerd Font Mono
          # Heavy Angle Brackets
          symbol_map U+276C-U+2771    Symbols Nerd Font Mono
          # Box Drawing
          symbol_map U+2500-U+259F    Symbols Nerd Font Mono
          # Progress
          symbol_map U+EE00-U+EE0B    Symbols Nerd Font Mono

          # MacOS fixes
          macos_titlebar_color system
        '';
      };
    };
  };
}

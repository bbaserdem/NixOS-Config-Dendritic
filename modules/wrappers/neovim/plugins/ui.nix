# UI element plugins;
{...}: {
  # External inputs
  flake-file.inputs = {
    neovim-plugin-e-ink-nvim = {
      url = "github:alexxGmZ/e-ink.nvim";
      flake = false;
    };
  };

  flake.wrappers.neovim = {
    pkgs,
    config,
    ...
  }: {
    config.specs = {
      # Specs for UI plugins

      # Status bar
      bar = {
        lazy = true;
        data = with pkgs.unstable.vimPlugins; [
          lualine-nvim # Statusline
          tabby-nvim # Tabline
        ];
      };

      # Color themes
      theme = {
        lazy = true;
        data = with pkgs.unstable.vimPlugins; [
          {
            lazy = false;
            data = nvim-web-devicons;
          }
          # Themes that may be used
          catppuccin-nvim
          cyberdream-nvim
          config.nvim-lib.neovimPlugins.e-ink-nvim
          gruvbox-nvim
          gruvbox-material-nvim
          kanagawa-nvim
          material-nvim
          melange-nvim
          nightfox-nvim
          onedark-nvim
        ];
      };

      # Picker
      picker = {
        lazy = true;
        data = with pkgs.unstable.vimPlugins; [
          telescope-nvim
          # Extensions
          telescope-manix
          telescope-fzf-native-nvim
          telescope-dap-nvim
          telescope-ui-select-nvim
        ];
        extraPackages = with pkgs.unstable; [
          ripgrep
          fd
        ];
      };

      # View menus
      views = {
        lazy = true;
        data = with pkgs.unstable.vimPlugins; [
          {
            lazy = false;
            data = snacks-nvim;
          }
          aerial-nvim # Code outline window
          fidget-nvim # Shows LSP progress in a text box
          trouble-nvim # Sidebar that shows diagnostics and such
          which-key-nvim # Shows keybind groups
          twilight-nvim # Dims inactive code
          mini-map # Code visual overview
          nvim-highlight-colors # Render colors with highlights
          satellite-nvim # Shows status signs on the right hand side
        ];
        extraPackages = with pkgs.unstable; [
          dwt1-shell-color-scripts
        ];
      };
    };
  };
}

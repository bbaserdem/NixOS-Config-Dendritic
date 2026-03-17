# Tools plugins;
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: let
    # Platform specific utils block
    platformUtils =
      if pkgs.stdenv.hostPlatform.isLinux
      then [
        pkgs.wl-clipboard
        pkgs.xclip
      ]
      else if pkgs.stdenv.hostPlatform.isDarwin
      then [
      ]
      else [];
  in {
    config.specs = {
      # Spects for tool plugins

      # AI tools
      ai = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          codecompanion-nvim
          claudecode-nvim
          claude-fzf-nvim
        ];
      };

      # Auto completion
      completion = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          # Completion
          blink-cmp
          blink-compat
          colorful-menu-nvim
          blink-cmp-tmux
          cmp-cmdline
          cmp-dap # We use this, not native cause native not in nixpkgs
          cmp-vimtex
          # Snippets
          luasnip
          friendly-snippets
          # Other
          lspkind-nvim # Add pictograms to built-in lsp for completion
        ];
      };

      # Debugger Adapter Protocol
      dap = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          nvim-dap # Debug adapter protocol for nvim
          nvim-dap-ui # DAP ui
          nvim-dap-virtual-text # DAP virtual text support
        ];
      };

      # File browsers
      files = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          yazi-nvim # File browser
          neo-tree-nvim # Sidebar file browser
          nvim-lsp-file-operations
          image-nvim
          fzf-lua
          {
            lazy = false;
            data = oil-nvim;
          }
          {
            lazy = false;
            data = oil-git-status-nvim;
          }
        ];
        extraPackages = with pkgs; [
          chafa
          imagemagick
        ];
      };

      # Formatting
      formatting = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          conform-nvim # Code formatter
          nvim-lint # Linter without LSP
        ];
        extraPackages = with pkgs; [
          harper # Grammar checking lsp, for all not just tex
        ];
      };

      # Version control
      vcs = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          gitsigns-nvim
          neogit
          codediff-nvim # Diff rendere like vscode
          hunk-nvim # Render jj diffs
          jj-nvim # jj integration
          {
            lazy = false;
            data = vim-jjdescription; # Syntax highlighting for jj descriptions
          }
        ];
      };

      # Supplementary vim motions
      motions = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          mini-ai
          mini-align
          mini-comment
          mini-move
          mini-pairs
          mini-splitjoin
          mini-surround
        ];
      };

      # Treesitter
      treesitter = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
          nvim-treesitter-textobjects
        ];
      };

      # Utilities
      utilities = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          mkdir-nvim # Automatically make directories when saving files
          urlview-nvim # Detects URLs
          bufdelete-nvim # Delete buffers without touching windows
          tmux-nvim # Integrate nvim with tmux
        ];
        extraPackages = platformUtils;
      };
    };
  };
}

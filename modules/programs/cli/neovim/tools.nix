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
      tools-ai = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          claudecode-nvim
          claude-fzf-nvim
          fzf-lua
          sidekick-nvim
          #agentic-nvim
        ];
        extraPackages = with pkgs; [
          copilot-cli
        ];
      };

      # Auto completion
      tools-completion = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          # Completion
          nvim-lspconfig # LSP default configuration
          nvim-cmp # Completion engine
          # Completion engines; general
          cmp_luasnip # Snippet suggestions
          cmp-nvim-lsp # LSP suggestions
          cmp-nvim-lsp-signature-help # LSP signature help
          cmp-async-path # Autocomplete from filesystem (no-block)
          cmp-rg # Ripgrep
          cmp-buffer # Buffer completion
          cmp-spell # Autocomplete from spelllang
          # Completion engines; commandline
          cmp-cmdline # Commandline completion
          cmp-cmdline-history # Commandline history completion
          # Completion engines; language
          cmp-vimtex # Vimtex source for cmp
          # Completion engines, other
          cmp-dap # DAP buffer completion
          # Snippets
          luasnip
          friendly-snippets
          # Other
          lspkind-nvim # Add pictograms to built-in lsp
        ];
      };

      # Debugger Adapter Protocol
      tools-dap = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          nvim-dap # Debug adapter protocol for nvim
          nvim-dap-ui # DAP ui
          nvim-dap-virtual-text # DAP virtual text support
        ];
      };

      # File browsers
      tools-files = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          yazi-nvim # File browser
          neo-tree-nvim # Sidebar file browser
          nvim-lsp-file-operations
          image-nvim
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
          imagemagick
        ];
      };

      # Formatting
      tools-formatting = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          conform-nvim # Code formatter
          nvim-lint # Linter without LSP
        ];
      };

      # Version control
      tools-vcs = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          gitsigns-nvim
          vim-fugitive
        ];
        extraPackages = with pkgs; [
          git
          lazygit
          gh
        ];
      };

      # Supplementary vim motions
      tools-motions = {
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
      tools-treesitter = {
        lazy = true;
        data = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
          nvim-treesitter-textobjects
        ];
      };

      # Utilities
      tools-utilities = {
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

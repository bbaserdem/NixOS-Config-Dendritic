-- Vimtex configuration, can't be lazy loaded (or type loaded) for inverse search to work

local M = {
  {
    "vimtex",
    auto_enable = true,
    lazy = false,
    before = function(plugin)
      -- Check if there is a nix override for this
      local _viewer
      nixInfo("zathura", "settings", "latex", "pdfViewer")

      -- Use a backend
      if _viewer == "okular" then
        vim.g.vimtex_view_method = "okular"
      elseif _viewer == "zathura" then
        vim.g.vimtex_view_method = "zathura"
      else
        vim.g.vimtex_view_method = "zathura"
      end

      -- Keep default keymaps, but add descriptions later using which-key
      vim.g.vimtex_mappings_enabled = true

      -- Settings
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = "LatexAux",
      }
      vim.g.vimtex_compiler_progname = "nvr"
      vim.g.vimtex_quickfix_method = "pplatex"
      vim.g.vimtex_quickfix_autoclose_after_keystrokes = 1
      vim.g.vimtex_quickfix_ignore_filters = {
        "Underfull",
        "Overfull",
        "Float too large",
      }
    end,
  },
}

return M

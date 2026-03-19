-- Catppuccin themeing

local M = {
  "catppuccin-nvim",
  auto_enable = true,
  on_require = "catppuccin",
  colorscheme = {
    "catppuccin",
    "catppuccin-latte",
    "catppuccin-frappe",
    "catppuccin-macchiato",
    "catppuccin-mocha",
  },
  dep_of = {
    "tabby.nvim",
  },
  after = function(plugin)
    -- Apply transparency setting
    local _trans = nixInfo(false, "settings", "colorscheme", "translucent")

    -- Run configuration
    -- Doesn't set the theme, just applies config
    require("catppuccin").setup({
      integrations = {
        aerial = true,
        blink_cmp = true,
        fidget = true,
        gitsigns = true,
        markdown = true,
        mason = true,
        mini = true,
        neotree = true,
        cmp = true,
        dap = true,
        dap_ui = true,
        treesitter_context = true,
        snacks = true,
        lsp_trouble = true,
        which_key = true,
      },
      transparent_background = _trans,
    })
  end,
}

return M

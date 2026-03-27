-- Material theme for nvim

local M = {
  "material.nvim",
  auto_enable = true,
  on_require = "material",
  colorscheme = {
    "material",
    "material-darker",
    "material-deep-ocean",
    "material-lighter",
    "material-oceanic",
    "material-palenight",
  },
  after = function(plugin)
    local _trans = nixInfo(false, "settings", "colorscheme", "translucent")

    -- Load us
    require("material").setup({
      plugins = {
        "dap",
        "fidget",
        "gitsigns",
        "mini",
        "neo-tree",
        "nvim-cmp",
        "nvim-web-devicons",
        "trouble",
        "which-key",
      },
      disable = {
        background = _trans,
      },
      lualine_style = "stealth",
    })
  end,
}

return M

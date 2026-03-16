-- Gruvbox material for nvim

local M = {
  "gruvbox-material.nvim",
  auto_enable = true,
  on_require = "gruvbox-material",
  colorscheme = {
    "gruvbox-material",
  },
  after = function(plugin)
    local _trans = nixInfo(false, "settings", "colorscheme", "translucent")

    -- Load us only if we are the main theme
    require("gruvbox-material").setup({
      background = {
        transparent = _trans,
      },
    })
  end,
}

return M

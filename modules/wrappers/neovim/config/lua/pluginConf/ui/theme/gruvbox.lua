-- Gruvbox for nvim

local M = {
  "gruvbox.nvim",
  auto_enable = true,
  on_require = "gruvbox",
  colorscheme = {
    "gruvbox",
  },
  dep_of = {
    -- Make sure we are loaded before lualine; themeing issues
    "lualine.nvim",
  },
  after = function(plugin)
    -- If nixCats, check to set defaults
    local _trans = nixInfo(false, "settings", "colorscheme", "translucent")

    -- Load us, doesn't auto-set the theme
    require("gruvbox").setup({
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = false,
      transparent_mode = _trans,
    })
  end,
}

return M

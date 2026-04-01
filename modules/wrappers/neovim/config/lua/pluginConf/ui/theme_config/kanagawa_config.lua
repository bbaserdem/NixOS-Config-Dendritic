-- Kanagawa for nvim

local M = {
  "kanagawa.nvim",
  auto_enable = true,
  on_require = "kanagawa",
  colorscheme = {
    "kanagawa-dragon",
    "kanagawa-lotus",
    "kanagawa-wave",
    "kanagawa",
  },
  after = function(plugin)
    local _trans = nixInfo(false, "settings", "colorscheme", "translucent")

    -- Load us
    require("kanagawa").setup({
      transparent = _trans,
    })
  end,
}

return M

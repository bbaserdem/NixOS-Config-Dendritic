-- Nightfox for nvim

local M = {
  "nightfox.nvim",
  auto_enable = true,
  on_require = "nightfox",
  colorscheme = {
    "carbonfox",
    "dawnfox",
    "dayfox",
    "duskfox",
    "nightfox",
    "nordfox",
    "terafox",
  },
  after = function(plugin)
    local _trans = nixInfo(false, "settings", "colorscheme", "translucent")

    -- Load us
    require("nightfox").setup({
      options = {
        transparent = _trans,
      },
    })
  end,
}

return M

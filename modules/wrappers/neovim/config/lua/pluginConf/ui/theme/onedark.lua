-- onedark for nvim

local M = {
  "onedark.nvim",
  auto_enable = true,
  on_require = "onedark",
  colorscheme = {
    "onedark",
  },
  after = function(plugin)
    local _trans = nixInfo(false, "settings", "colorscheme", "translucent")

    -- Load us
    require("onedark").setup({
      transparent = _trans,
    })
  end,
}

return M

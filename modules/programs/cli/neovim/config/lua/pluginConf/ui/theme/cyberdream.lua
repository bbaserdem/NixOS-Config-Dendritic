-- Cyberdream for nvim

local M = {
  "cyberdream.nvim",
  auto_enable = true,
  on_require = "cyberdream",
  colorscheme = {
    "cyberdream",
  },
  after = function(plugin)
    -- This theme is transparent-first, enforce transparency
    -- local _trans = nixInfo(true, "settings", "colorscheme", "translucent")
    local _trans = true

    -- Load us
    require("cyberdream").setup({
      variant = "auto",
      transparent = _trans,
    })
  end,
}

return M

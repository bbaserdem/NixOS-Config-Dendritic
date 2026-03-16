-- E-ink grayscale theme for nvim

local M = {
  "e-ink.nvim",
  auto_enable = true,
  on_require = "e-ink",
  colorscheme = {
    "e-ink",
  },
  after = function(plugin)
    -- Load us
    require("e-ink").setup()
  end,
}

return M

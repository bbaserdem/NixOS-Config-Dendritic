-- E-ink grayscale theme for nvim

local M = {
  "e-ink-nvim", -- name is with dash due to nix restrictions
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

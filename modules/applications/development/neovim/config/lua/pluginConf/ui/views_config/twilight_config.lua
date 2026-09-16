-- Inactive code dimmer

local M = {
  {
    "twilight.nvim",
    auto_enable = true,
    cmd = {
      "Twilight",
      "TwilightEnable",
      "TwilightDisable",
    },
    on_require = { "twilight" },
    after = function(plugin)
      require("twilight").setup({
        dimming = {
          alpha = 0.40,
          inactive = false,
        },
      })
    end,
  },
}

return M

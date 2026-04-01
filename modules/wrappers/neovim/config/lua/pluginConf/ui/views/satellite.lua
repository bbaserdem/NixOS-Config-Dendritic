-- LSP status rendering

local M = {
  {
    "satellite.nvim",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    cmd = {
      "SatelliteRefresh",
      "SatelliteEnable",
      "SatelliteDisable",
    },
    on_require = { "satellite" },
    after = function(plugin)
      require("satellite").setup({
        current_only = true,
      })
    end,
  },
}

return M

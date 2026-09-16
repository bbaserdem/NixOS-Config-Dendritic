-- Render code outline as a map

local M = {
  {
    "mini.map",
    auto_enable = true,
    on_require = "mini.map",
    event = { "DeferredUIEnter" },
    after = function(plugin)
      local map = require("mini.map")
      map.setup({
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic(),
          map.gen_integration.gitsigns(),
        },
      })
    end,
  },
}

return M

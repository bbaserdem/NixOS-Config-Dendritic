-- Luasnip config

local M = {
  {
    "friendly-snippets",
    auto_enable = true,
    dep_of = {
      "blink.cmp",
    },
  },
  {
    "luasnip",
    auto_enable = true,
    dep_of = {
      "blink.cmp",
    },
    on_require = "luasnip",
    after = function(plugin)
      local luasnip = require("luasnip")

      -- Needed for friendly snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      -- require("luasnip.loaders.from_vscode").lazy_load({ paths = { "../../../../snippets" } })

      luasnip.config.setup({})
    end,
  },
}

return M

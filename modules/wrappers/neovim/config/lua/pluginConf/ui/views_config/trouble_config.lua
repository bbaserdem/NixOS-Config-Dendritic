-- Diagnostics outline

local M = {
  {
    "trouble.nvim",
    auto_enable = true,
    on_require = "trouble",
    dep_of = {
      "lualine.nvim",
    },
    cmd = { "Trouble" },
    -- We want deferreduienter to modify the gutter icons
    event = { "DeferredUIEnter" },
    after = function(plugin)
      require("trouble").setup({
        icons = {
          top = "║ ",
          middle = "╟─",
          last = "╙─",
          fold_open = " ",
          fold_closed = " ",
          ws = "  ",
        },
        picker = {
          actions = require("trouble.sources.snacks").actions,
          win = {
            input = {
              keys = {
                ["<c-t>"] = {
                  "trouble_open",
                  mode = { "n", "i" },
                },
              },
            },
          },
        },
      })
    end,
  },
}

return M

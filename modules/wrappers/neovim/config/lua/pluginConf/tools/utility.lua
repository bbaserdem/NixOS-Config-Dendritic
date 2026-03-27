-- Extra utilities config

local M = {
  { -- Display url's in a picker view
    "urlview.nvim",
    auto_enable = true,
    on_require = "urlview",
    cmd = { "UrlView" },
    after = function(plugin)
      require("urlview").setup({
        default_picker = "native",
        default_action = "system",
        default_register = "+",
        unique = true,
        sorted = false,
      })
    end,
  },
  { -- Delete buffers without closing windows
    "bufdelete.nvim",
    auto_enable = true,
    on_require = "bufdelete",
    cmd = {
      "Bdelete",
      "Bwipeout",
    },
  },
  { -- Make directories for buffers
    "mkdir.nvim",
    auto_enable = true,
    event = { "DeferredUIEnter" },
  },
  { -- Tmux integration
    "tmux.nvim",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    after = function(plugin)
      require("tmux").setup({})
    end,
  },
}

return M

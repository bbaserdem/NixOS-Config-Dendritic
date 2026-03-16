-- Snacks configuration for some ui elements

local M = {
  "snacks.nvim",
  auto_enable = true,
  lazy = false,
  after = function(plugin)
    require("snacks").setup({
      -- Enabled plugins
      dashboard = require("pluginConf.ui.views.snacks.dashboard"),
      gh = { enabled = true },
      indent = require("pluginConf.ui.views.snacks.indent"),
      input = { enabled = true },
      notifier = require("pluginConf.ui.views.snacks.notifier"),
      scroll = { enabled = true },
      toggle = require("pluginConf.ui.views.snacks.toggle"),
      -- Disabled plugins, we don't even load them
      -- If they are explicitly disabled, they still get require calls
      -- Messes up with other plugins setting integrations with unused features
      -- bigfile = { enabled = false },
      -- bufdelete = { enabled = false },
      -- debug = { enabled = false },
      -- dim = { enabled = false },
      -- gitbrowse = { enabled = false },
      -- image = { enabled = false },
      -- keymap = { enabled = false },
      -- layout = { enabled = false },
      -- lazygit = { enabled = false },
      -- picker = { enabled = false },
      -- profiler = { enabled = false },
      -- quickfile = { enabled = false },
      -- rename = { enabled = false },
      -- scratch = { enabled = false },
      -- statuscolumn = { enabled = false },
      -- terminal = { enabled = false },
      -- win = { enabled = false },
      -- words = { enabled = false },
      -- zen = { enabled = false },
      -- Disabled plugins, if they are set disabled, they still get require calls
    })
  end,
}

return M

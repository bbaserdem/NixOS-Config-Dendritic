-- Git tooling

local M = {
  { -- Git status signs in the num column
    "gitsigns.nvim",
    auto_enable = true,
    on_require = "gitsigns",
    cmd = {
      "Gitsigns",
    },
    event = { "DeferredUIEnter" },
    after = function(plugin)
      require("gitsigns").setup({
        numhl = true,
        attach_to_untracked = false,
      })
    end,
  },
  { -- Git commands, non-lua plugin
    "neogit",
    auto_enable = true,
    cmd = {
      "Neogit",
    },
    on_require = "neogit",
    after = function(plugin)
      require("neogit").setup({
        graph_style = "unicode",
        integrations = {
          snacks = false,
          mini_pick = false,
        },
      })
    end,
  },
  {
    "codediff.nvim",
    auto_enable = true,
    cmd = {
      "CodeDiff",
    },
    on_require = {
      "codediff",
      "codediff.diff",
      "codediff.ui",
      "codediff.git",
    },
    after = function(plugin)
      require("codediff").setup({})
    end,
  },
}

return M

-- Code diff renderer

local M = {
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

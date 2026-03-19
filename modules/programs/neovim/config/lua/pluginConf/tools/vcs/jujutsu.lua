-- Jujutsu tooling

local M = {
  { -- Render jujutsu diffs in neovim
    "hunk.nvim",
    auto_enable = true,
    on_require = "hunk",
    cmd = {
      "DiffEditor",
    },
    dep_of = {
      "jj.nvim",
    },
    after = function(plugin)
      require("hunk").setup({})
    end,
  },
  { -- Render jujutsu diffs in neovim
    "jj.nvim",
    auto_enable = true,
    on_require = {
      "jj",
      "jj.cmd",
    },
    cmd = {
      "J",
      "Jdiff",
      "Jvdiff",
      "Jhdiff",
    },
    after = function(plugin)
      require("jj").setup({})
    end,
  },
  { -- Syntax highlighting for jj descriptions
    "vim-jjdescription",
    auto_enable = true,
    lazy = false,
  },
}

return M

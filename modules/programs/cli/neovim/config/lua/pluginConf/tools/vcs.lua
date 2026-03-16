-- Version control tooling

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
    "vim-fugitive",
    auto_enable = true,
    cmd = {
      "Git",
      "Gedit",
      "Gsplit",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GRename",
      "GDelete",
      "GBrowse",
    },
  },
}

return M

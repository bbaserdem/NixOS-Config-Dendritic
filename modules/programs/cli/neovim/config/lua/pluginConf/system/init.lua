-- Load system plugins through lze
-- lze and lzeextras were already loaded

local M = {
  -- { import = "pluginConf.system.darklight" },
  {
    "plenary.nvim",
    auto_enable = true,
    dep_of = {
      "yazi.nvim",
      "neo-tree.nvim",
      "telescope.nvim",
    },
  },
  {
    "nui.nvim",
    auto_enable = true,
    dep_of = {
      "neo-tree.nvim",
      "telescope.nvim",
      "codediff.nvim",
      "hunk.nvim",
    },
  },
  {
    "nvim-nio",
    auto_enable = true,
    dep_of = {
      "nvim-dap-ui",
    },
  },
  {
    "mini.base16",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    colorscheme = {
      "minicyan",
      "minischeme",
      "minicrimson",
      "stylix",
    },
  },
}

return M

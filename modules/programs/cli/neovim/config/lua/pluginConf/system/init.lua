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
    "nvim-lspconfig",
    auto_enable = true,
    lazy = false,
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

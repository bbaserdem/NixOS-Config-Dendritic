-- Debug adapter protocol

local M = {
  {
    "nvim-dap",
    auto_enable = true,
    dep_of = {
      "nvim-dap-ui",
      "nvim-dap-virtual-text",
      "nvim-dap-python",
      "cmp-dap",
    },
    on_require = "dap",
    cmd = {
      "DapNew",
    },
  },
  {
    "nvim-dap-ui",
    auto_enable = true,
    dep_of = {
      "lazydev.nvim",
    },
    on_require = "dapui",
    after = function(plugin)
      require("dapui").setup()
    end,
  },
  {
    "nvim-dap-virtual-text",
    auto_enable = true,
    on_plugin = {
      "nvim-dap-ui",
      "nvim-dap",
    },
    on_require = "nvim-dap-virtual-text",
    after = function(plugin)
      require("nvim-dap-virtual-text").setup({})
    end,
  },
}

return M

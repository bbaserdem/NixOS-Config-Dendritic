-- Python plugins

local M = {
  {
    "nvim-dap-python",
    auto_enable = true,
    ft = {
      "python",
    },
    on_require = "dap-python",
    after = function(plugin)
      require("dap-python").setup("python3")
    end,
  },
}

return M

-- Lazydev config

local M = {
  {
    "lazydev.nvim",
    auto_enable = true,
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(plugin)
      require("lazydev").setup({
        library = {
          "nvim-dap-ui",
          {
            words = { "nixInfo%.lze" },
            path = nixInfo("lze", "plugins", "start", "lze") .. "/lua",
          },
          {
            words = { "nixInfo%.lze" },
            path = nixInfo("lzextras", "plugins", "start", "lze") .. "/lua",
          },
        },
      })
    end,
  },
}

return M

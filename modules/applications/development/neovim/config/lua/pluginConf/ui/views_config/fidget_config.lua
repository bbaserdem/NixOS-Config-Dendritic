-- LSP status rendering

local M = {
  {
    "fidget.nvim",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    cmd = { "Fidget" },
    on_require = { "fidget" },
    after = function(plugin)
      require("fidget").setup({
        notification = {
          window = {
            winblend = 0,
          },
        },
      })
    end,
  },
}

return M

-- Yazi: File browser integration

local M = {
  {
    "yazi.nvim",
    auto_enable = true,
    cmd = "Yazi",
    on_require = "yazi",
    after = function(plugin)
      require("yazi").setup({
        open_for_directories = false,
      })
    end,
  },
}

return M

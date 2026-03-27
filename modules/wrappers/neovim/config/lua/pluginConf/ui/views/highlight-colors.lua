-- Render hex color codes as highlights

local M = {
  {
    "nvim-highlight-colors",
    auto_enable = true,
    dep_of = { "nvim-cmp" },
    on_require = "nvim-highlight-colors",
    cmd = {
      "HighlightColors",
    },
    event = { "DeferredUIEnter" },
    after = function(plugin)
      require("nvim-highlight-colors").setup({})
    end,
  },
}

return M

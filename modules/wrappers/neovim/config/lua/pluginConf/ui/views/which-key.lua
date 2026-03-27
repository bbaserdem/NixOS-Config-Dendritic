-- Render keyboard shortcuts as a screen

local M = {
  {
    "which-key.nvim",
    auto_enable = true,
    on_require = "which-key",
    event = { "DeferredUIEnter" },
    after = function(plugin)
      require("which-key").setup({
        preset = "helix",
        delay = 0,
        notify = true,
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
          presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windown = true,
            nav = true,
            z = true,
            g = true,
          },
        },
        show_help = true,
        show_keys = true,
      })
    end,
  },
}

return M

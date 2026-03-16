-- AI tooling to work with neovim

local M = {
  {
    "codecompanion.nvim",
    auto_enable = true,
    on_require = "codecompanion",
    after = function(plugin)
      require("codecompanion").setup({})
    end,
  },
  {
    "sidekick.nvim",
    auto_enable = true,
    on_require = {
      "sidekick",
      "sidekick.nes",
      "sidekick.cli",
    },
    cmd = {
      "Sidekick",
    },
    after = function(plugin)
      require("sidekick").setup({
        cli = {
          mux = {
            enabled = false,
            backend = "tmux",
          },
        },
      })
    end,
  },
}

return M

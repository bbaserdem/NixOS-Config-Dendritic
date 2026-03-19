-- Fzf- quick file browser

local M = {
  { -- Req for claude-fzf.nvim
    "fzf-lua",
    auto_enable = true,
    dep_of = {
      "claude-fzf.nvim",
    },
    cmd = {
      "FzfLua",
    },
    on_require = "fzf-lua",
    after = function(plugin)
      require("fzf-lua").setup({
        previewers = {
          builtin = {
            extensions = {
              ["png"] = { "chafa", "{file}" },
              ["svg"] = { "chafa", "{file}" },
              ["jpg"] = { "chafa", "{file}" },
              ["jpeg"] = { "chafa", "{file}" },
            },
          },
        },
      })
    end,
  },
}

return M

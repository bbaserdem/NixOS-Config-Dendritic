-- Aerial config

local M = {
  {
    "aerial.nvim",
    auto_enable = true,
    cmd = {
      "AerialToggle",
      "AerialOpen",
      "AerialOpenAll",
      "AerialClose",
      "AerialCloseAll",
      "AerialNext",
      "AerialPrev",
      "AerialGo",
      "AerialInfo",
      "AerialNavToggle",
      "AerialNavOpen",
      "AerialNavClose",
    },
    dep_of = {
      "lualine.nvim",
    },
    on_require = { "aerial" },
    after = function(plugin)
      require("aerial").setup({
        backends = { "lsp", "treesitter", "markdown", "man", "asciidoc" },
        layout = {
          default_direction = "prefer_left",
        },
        lazy_load = false,
        attach_mode = "global",
        show_guides = true,
        guides = {
          mid_item = "╠═",
          last_item = "╚═",
          nested_top = "║ ",
          whitespace = "  ",
        },
        float = {
          border = "rounded",
          relative = "win",
        },
      })
    end,
  },
}

return M

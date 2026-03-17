-- Markdown plugins

local M = {
  { -- Preview
    "glow.nvim",
    auto_enable = true,
    ft = {
      "markdown",
    },
    on_require = "glow",
    cmd = { "Glow" },
    after = function(plugin)
      require("glow").setup({})
    end,
  },
  { -- Navigating markdown links
    "mkdnflow.nvim",
    auto_enable = true,
    ft = {
      "markdown",
      "md",
      "rmd",
    },
    dep_of = {
      "blink.cmp",
    },
    on_require = "mkdnflow",
    after = function(plugin)
      require("mkdnflow").setup({
        modules = {
          completion = true,
        },
      })
    end,
  },
  { -- Markdown rendering
    "render-markdown.nvim",
    auto_enable = true,
    ft = {
      "markdown",
    },
    cmd = { "RenderMarkdown" },
    on_require = "render-markdown",
    after = function(plugin)
      require("render-markdown").setup({
        enabled = true,
        render_modes = { "n", "c", "t" },
        quote = {
          repeat_linebreak = true,
        },
        latex = {
          enabled = true,
          converter = { "latex2text" },
        },
        heading = {
          enabled = true,
          sign = true,
          position = "inline",
          width = "block",
          left_pad = 2,
          right_pad = 42,
          min_width = 30,
        },
        max_file_size = 10.0,
        pipe_table = {
          preset = "double",
          cell = "trimmed",
        },
      })
    end,
  },
}

return M

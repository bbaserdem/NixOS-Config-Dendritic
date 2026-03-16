-- Blink-cmp sources

local M = {
  {
    "blink.compat",
    auto_enable = true,
    dep_of = {
      "cmp-cmdline",
      "cmp-dap",
      "cmp-vimtex",
    },
  },
  {
    "cmp-cmdline",
    auto_enable = true,
    on_plugin = {
      "blink.cmp",
    },
    load = nixInfo.lze.loaders.with_after,
  },
  {
    "cmp-dap",
    auto_enable = true,
    on_plugin = {
      "blink.cmp",
    },
    load = nixInfo.lze.loaders.with_after,
  },
  {
    "cmp-vimtex",
    auto_enable = true,
    on_plugin = {
      "blink.cmp",
    },
    load = nixInfo.lze.loaders.with_after,
  },
  {
    "blink-cmp-tmux",
    auto_enable = true,
    on_plugin = {
      "blink.cmp",
    },
  },
}

return M

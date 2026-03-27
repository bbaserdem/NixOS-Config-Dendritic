-- Language specific plugin entry point

local M = {
  { import = "pluginConf.languages.latex" },
  { import = "pluginConf.languages.lua" },
  { import = "pluginConf.languages.markdown" },
  { import = "pluginConf.languages.python" },
  { -- Equation parser, for both markdown and latex so just put it here
    "nabla.nvim",
    auto_enable = true,
    ft = {
      "markdown",
      "latex",
      "tex",
    },
    on_require = "nabla",
  },
}

return M

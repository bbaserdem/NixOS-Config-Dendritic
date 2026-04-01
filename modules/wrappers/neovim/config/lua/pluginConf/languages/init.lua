-- Language specific plugin entry point

local M = {
  { import = "pluginConf.languages.latex_config" },
  { import = "pluginConf.languages.lean_config" },
  { import = "pluginConf.languages.lua_config" },
  { import = "pluginConf.languages.markdown_config" },
  { import = "pluginConf.languages.python_config" },
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

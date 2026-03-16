-- Tool plugins config

local M = {
  { import = "pluginConf.tools.ai" },
  { import = "pluginConf.tools.completion" },
  { import = "pluginConf.tools.debug" },
  { import = "pluginConf.tools.files" },
  { import = "pluginConf.tools.formatting" },
  { import = "pluginConf.tools.motions" },
  { import = "pluginConf.tools.treesitter" },
  { import = "pluginConf.tools.utility" },
  { import = "pluginConf.tools.vcs" },
}

return M

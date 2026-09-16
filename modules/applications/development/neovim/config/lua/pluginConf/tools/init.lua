-- Tool plugins config

local M = {
  { import = "pluginConf.tools.ai_config" },
  { import = "pluginConf.tools.completion_config" },
  { import = "pluginConf.tools.debug_config" },
  { import = "pluginConf.tools.files_config" },
  { import = "pluginConf.tools.formatting_config" },
  { import = "pluginConf.tools.motions_config" },
  { import = "pluginConf.tools.treesitter_config" },
  { import = "pluginConf.tools.utility_config" },
  { import = "pluginConf.tools.vcs_config" },
}

return M

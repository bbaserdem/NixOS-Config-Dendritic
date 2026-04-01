-- <nixCats>/lua/pluginConf/ui/init.lua
-- Lazy loaded plugins config

-- Plugin configs, with one call to lze
local M = {
  { import = "pluginConf.ui.bar_config" },
  { import = "pluginConf.ui.theme_config" },
  { import = "pluginConf.ui.picker_config" },
  { import = "pluginConf.ui.views_config" },
}

return M

-- Lazy loaded plugins config

-- Bootstrap plugins if needed first
-- require("pluginConf.paq")

-- Plugin configs, with call to lze
nixInfo.lze.load({
  { import = "pluginConf.system" },
  { import = "pluginConf.tools" },
  { import = "pluginConf.ui" },
  { import = "pluginConf.languages" },
})

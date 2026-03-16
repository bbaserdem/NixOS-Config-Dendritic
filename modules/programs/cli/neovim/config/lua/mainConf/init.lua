-- Nvim configuration entry

-- Do our global settings
require("mainConf.myOptions")

-- Load plugin configurations
require("pluginConf")

-- Apply colorscheme after plugins are registered with lze
require("mainConf.myColorscheme")

-- Load Autocommands
require("mainConf.myAutocmd")

-- LSP global configuration
-- require("mainConf.myLspGlobal")

-- Load Keybinds
-- require("keymapConf")

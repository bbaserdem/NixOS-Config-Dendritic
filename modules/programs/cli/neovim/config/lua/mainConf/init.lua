-- Nvim configuration entry

-- Load our global settings
require("mainConf.myOptions")

-- Load plugin configurations
require("pluginConf")

-- Load LSP configurations
require("lspConf")

-- Apply colorscheme after plugins are registered with lze
require("mainConf.myColorscheme")

-- Load Autocommands
require("mainConf.myAutocmd")

-- LSP global configuration
-- require("mainConf.myLspGlobal")

-- Load Keybinds
-- require("keymapConf")

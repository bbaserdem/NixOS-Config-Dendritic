-- Nvim configuration entry

-- Load our global settings
require("mainConf.behavior")
require("mainConf.options")

-- Load plugin configurations
require("pluginConf")
-- Load LSP configurations
require("lspConf")

-- Apply colorscheme after plugins are registered with lze
require("mainConf.colorscheme")

-- Load Keybinds
require("keymapConf")

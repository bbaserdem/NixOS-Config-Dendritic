-- Nvim configuration entry

-- Load our global settings
require("mainConf.behavior")
require("mainConf.options")
require("mainConf.neovide")

-- Load plugin configurations
require("pluginConf")
-- Load LSP configurations
require("lspConf")
-- Load Keybinds
require("keymapConf")
-- Apply colorscheme (after plugins are registered with lze)
require("mainConf.colorscheme")

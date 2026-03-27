-- Set up the color scheme

-- If not nix, or not configured; use e-ink
local _polarity = nixInfo("dark", "settings", "colorscheme", "default")
local _theme = nixInfo("e-ink", "settings", "colorscheme", _polarity)

-- Load the specific colorscheme
vim.o.background = _polarity
vim.cmd.colorscheme(_theme)

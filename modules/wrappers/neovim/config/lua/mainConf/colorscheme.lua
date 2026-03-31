-- Set up the color scheme

-- If not nix, or not configured; use e-ink
local _polarity = nixInfo("dark", "settings", "colorscheme", "default")
local _theme = nixInfo("e-ink", "settings", "colorscheme", _polarity)

-- Load the specific colorscheme, or use predefined theme in neovide
if vim.g.neovide then
  vim.o.background = _polarity
  vim.cmd.colorscheme(_theme)
else
  vim.o.background = _polarity
  vim.cmd.colorscheme(_theme)
end

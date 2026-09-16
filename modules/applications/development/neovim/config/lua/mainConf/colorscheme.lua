-- Set up the color scheme

-- function to apply proper theme
local function apply_theme()
  local _theme
  local _polarity = vim.o.background
  if vim.g.neovide then
    _theme = nixInfo(nil, "settings", "colorscheme", "gui-" .. _polarity) or "gruvbox-material"
  else
    _theme = nixInfo(nil, "settings", "colorscheme", _polarity) or "e-ink"
  end

  vim.cmd.colorscheme(_theme)
end

-- Neovide does the detection itself
if not vim.g.neovide then
  -- Set background, default to dark
  vim.o.background = nixInfo(nil, "settings", "colorscheme", "default") or "dark"
end

-- Apply our theme
apply_theme()

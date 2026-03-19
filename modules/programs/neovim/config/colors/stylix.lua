-- Stylix integration with nixCats

-- The stylix base16 array should be provided in the settings.colorscheme.base16
-- The transparency setting should be provided in settings.colorscheme.translucent

-- Default to paraiso theme, if stylix is unconfigured
local _theme = nixInfo(nil, "settings", "colorscheme", "base16")
  or {
    base00 = "#2f1e2e", -- ----
    base01 = "#41323f", -- ---
    base02 = "#4f424c", -- --
    base03 = "#776e71", -- -
    base04 = "#8d8687", -- +
    base05 = "#a39e9b", -- ++
    base06 = "#b9b6b0", -- +++
    base07 = "#e7e9db", -- ++++
    base08 = "#ef6155", -- red
    base09 = "#f99b15", -- orange
    base0A = "#fec418", -- yellow
    base0B = "#48b685", -- green
    base0C = "#5bc4bf", -- aqua
    base0D = "#06b6ef", -- blue
    base0E = "#815ba4", -- purple
    base0F = "#e96ba8", -- brown
  }
-- Could get the translucency flag, but it's not used by mini.base16
-- local _trans = nixInfo(nil, "settings", "colorscheme", "translucent") or false

-- Load the colorscheme, use mini.base16
require("mini.base16").setup({
  palette = _theme,
  plugins = {
    default = true,
  },
})

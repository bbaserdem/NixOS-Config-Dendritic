-- Stylix integration with nixCats

-- The stylix base16 array should be provided in the settings.colorscheme.base16
-- The transparency setting should be provided in settings.colorscheme.translucent
local mini16 = require("mini.base16")

-- Helper to flip base16 polarity (Dark <-> Light)
local function flip_polarity(palette)
  if not palette then
    return nil
  end
  return {
    -- Flip background colors
    base00 = palette.base07,
    base01 = palette.base06,
    base02 = palette.base05,
    base03 = palette.base04,
    base04 = palette.base03,
    base05 = palette.base02,
    base06 = palette.base01,
    base07 = palette.base00,
    -- Accents stay the same
    base08 = palette.base08,
    base09 = palette.base09,
    base0A = palette.base0A,
    base0B = palette.base0B,
    base0C = palette.base0C,
    base0D = palette.base0D,
    base0E = palette.base0E,
    base0F = palette.base0F,
  }
end

local function apply_theme()
  -- Only do if we are stylix named
  if vim.g.colors_name ~= "stylix" then
    return
  end

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
  -- Also get polarity info, assume dark by default
  local _polarity = nixInfo(nil, "settings", "colorscheme", "base16-polarity") or "dark"

  -- Flip palette if needed
  local _palette
  if _polarity == "dark" and vim.o.background == "light" then
    _palette = flip_polarity(_theme)
  elseif _polarity == "light" and vim.o.background == "dark" then
    _palette = flip_polarity(_theme)
  else
    _palette = _theme
  end

  -- Set up theme using base-16
  mini16.setup({ palette = _palette })

  -- Set up transparency if needed
  if nixInfo(false, "settings", "colorscheme", "translucent") then
    -- Transparent background
    vim.cmd.highlight({ "Normal", "guibg=NONE", "ctermbg=NONE" })
    vim.cmd.highlight({ "NonText", "guibg=NONE", "ctermbg=NONE" })
    -- Transparent sign column
    vim.cmd.highlight({ "SignColumn", "guibg=NONE", "ctermbg=NONE" })
    -- Transparent number line
    vim.cmd.highlight({ "LineNr", "guibg=NONE", "ctermbg=NONE" })
    vim.cmd.highlight({ "LineNrAbove", "guibg=NONE", "ctermbg=NONE" })
    vim.cmd.highlight({ "LineNrBelow", "guibg=NONE", "ctermbg=NONE" })
  end

  -- Set our name
  vim.g.colors_name = "stylix"
end

-- Load us on initial load.
vim.g.colors_name = "stylix"
apply_theme()

-- Auto-toggle on background change
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  callback = function()
    if vim.g.colors_name == "stylix" then
      apply_theme()
    end
  end,
})

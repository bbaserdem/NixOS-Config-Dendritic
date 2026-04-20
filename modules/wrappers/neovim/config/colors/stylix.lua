-- Stylix integration with nixCats

-- The stylix base16 array should be provided in the settings.colorscheme.base16
-- The transparency setting should be provided in settings.colorscheme.translucent
local mini16 = require("mini.base16")

-- Default to chalk (dark) theme when absent
local _theme_dark = nixInfo(nil, "settings", "colorscheme", "base16", "dark")
  or {
    base00 = "#151515", -- ----
    base01 = "#202020", -- ---
    base02 = "#303030", -- --
    base03 = "#505050", -- -
    base04 = "#b0b0b0", -- +
    base05 = "#d0d0d0", -- ++
    base06 = "#e0e0e0", -- +++
    base07 = "#f5f5f5", -- ++++
    base08 = "#fb9fb1", -- red
    base09 = "#eda987", -- orange
    base0A = "#ddb26f", -- yellow
    base0B = "#acc267", -- green
    base0C = "#12cfc0", -- aqua
    base0D = "#6fc2ef", -- blue
    base0E = "#e1a3ee", -- purple
    base0F = "#deaf8f", -- brown
  }
-- Default to sagelight (light) theme when absent
local _theme_light = nixInfo(nil, "settings", "colorscheme", "base16", "dark")
  or {
    base00 = "#f8f8f8", -- ----
    base01 = "#e8e8e8", -- ---
    base02 = "#d8d8d8", -- --
    base03 = "#b8b8b8", -- -
    base04 = "#585858", -- +
    base05 = "#383838", -- ++
    base06 = "#282828", -- +++
    base07 = "#181818", -- ++++
    base08 = "#fa8480", -- red
    base09 = "#ffaa61", -- orange
    base0A = "#ffdc61", -- yellow
    base0B = "#a0d2c8", -- green
    base0C = "#a2d6f5", -- aqua
    base0D = "#a0a7d2", -- blue
    base0E = "#c8a0d2", -- purple
    base0F = "#d2b2a0", -- brown
  }

local function apply_theme()
  -- Only do if we are stylix named
  if vim.g.colors_name ~= "stylix" then
    return
  end

  -- Apply corresponding palette
  if vim.o.background == "light" then
    mini16.setup({ palette = _theme_light })
  elseif vim.o.background == "dark" then
    mini16.setup({ palette = _theme_dark })
  else
    -- Default to dark
    mini16.setup({ palette = _theme_dark })
  end

  -- Set up transparency if wanted
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

  -- Set our name as the current theme
  vim.g.colors_name = "stylix"
end

-- Load us once when set
vim.g.colors_name = "stylix"
apply_theme()

-- Auto-toggle on background change
local _group = vim.api.nvim_create_augroup("StylixTheme", { clear = true })
vim.api.nvim_create_autocmd("OptionSet", {
  group = _group,
  pattern = "background",
  callback = function()
    if vim.g.colors_name == "stylix" then
      apply_theme()
    end
  end,
})

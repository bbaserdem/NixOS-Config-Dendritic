-- Mini colorscheme for red tint
local mini16 = require("mini.base16")

local function apply_theme()
  -- Only run if we are active theme
  if vim.g.colors_name ~= "minicrimson" then
    return
  end

  -- Get proper color palette
  local palette = vim.o.background == "dark" and mini16.mini_palette("#401603", "#ffa6ce") -- Dark variant
    or mini16.mini_palette("#fff0f0", "#800020") -- Light variant

  -- Change our colorscheme
  mini16.setup({ palette = palette })

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

  -- Set our name after switching, mini16.setup sets it to null
  vim.g.colors_name = "minicrimson"
end

-- Run on loading theme
vim.g.colors_name = "minicrimson"
apply_theme()

local _group = vim.api.nvim_create_augroup("CrimsonTheme", { clear = true })
vim.api.nvim_create_autocmd("OptionSet", {
  group = _group,
  pattern = "background",
  callback = function()
    if vim.g.colors_name == "minicrimson" then
      apply_theme()
    end
  end,
})

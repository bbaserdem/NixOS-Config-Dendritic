-- Main behavioral settings

-- Needs to be setup before everything, global and local leader key
vim.api.nvim_set_keymap("", " ", "", { noremap = true })
vim.api.nvim_set_keymap("", "\\", "", { noremap = true })
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Copy pasting in wayland
if os.getenv("WAYLAND_DISPLAY") and vim.fn.exepath("wl-copy") ~= "" then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy",
    },
    paste = {
      ["+"] = "wl-paste",
      ["*"] = "wl-paste",
    },
    cache_enabled = 1,
  }
end

-- Display some whitespace characters
vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

--[[
-- Spelling options
-- I deprecated this in favor of not having spelling sources pollute flake inputs
-- Initially this was done since languagetool doesn't have turkish
-- I don't use turkish writing that much in neovim anyway, so not super useful
-- Spellchecking often lacks terminology, so many false positives are annoying
-- Currently, I use ltex for grammar checking in markup languages
-- Do want to switch to harper due to AI inclusion in languagetool
vim.opt.spelllang = { "en", "tr" }
if nixInfo(true, "settings", "spelling") then
  vim.opt.spell = true -- Turn on spellchecking
else
  vim.opt.spell = false -- Turn on spellchecking
end
--]]

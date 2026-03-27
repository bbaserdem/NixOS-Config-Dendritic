-- Keybinds entry point

-- Leader keybinds for each functionality
require("keymapConf.ai")
require("keymapConf.buffer")
require("keymapConf.code")
require("keymapConf.debug")
require("keymapConf.files")
require("keymapConf.git")
require("keymapConf.jujutsu")
require("keymapConf.navigation")
require("keymapConf.search")
require("keymapConf.ui")

-- Specific file-type keymaps, uses localleader
require("keymapConf.latex")

-- Load which-key group names
local wk_status, wk = pcall(require, "which-key")
if wk_status then
  wk.add({
    { "<Leader>a", group = "[A]I tools" },
    { "<Leader>b", group = "[B]uffer functions" },
    { "<Leader>c", group = "[C]ode linting & formatting" },
    { "<Leader>d", group = "[D]ebug" },
    { "<Leader>f", group = "[F]ile operations" },
    { "<Leader>g", group = "[G]it functions" },
    { "<Leader>j", group = "[J]ujutsu functions" },
    { "<Leader>s", group = "[S]earch functions" },
    { "<Leader>u", group = "[U]I elements" },
    { "<Leader>n", group = "[N]avigation commands" },
  })
end

-- System clipboard functions
vim.keymap.set({ "n", "v", "x" }, "<C-a>", "gg0vG$", { noremap = true, silent = true, desc = "Select all" })
vim.keymap.set({ "v", "x", "n" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
vim.keymap.set(
  { "n", "v", "x" },
  "<leader>Y",
  '"+yy',
  { noremap = true, silent = true, desc = "Yank line to clipboard" }
)
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set(
  "x",
  "<leader>P",
  '"_dP',
  { noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)
vim.keymap.set(
  "i",
  "<C-p>",
  "<C-r><C-p>+",
  { noremap = true, silent = true, desc = "Paste from clipboard from within insert mode" }
)

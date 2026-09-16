-- <Leader>g: Git operations

-- Neogit
vim.keymap.set("n", "<Leader>gg", "<cmd>Neogit<CR>", { desc = "Open Neo[g]it" })

-- Telescope
vim.keymap.set("n", "<Leader>gf", "<cmd>Telescope git_files<CR>", { desc = "Search git ls-files" })
vim.keymap.set("n", "<Leader>gC", "<cmd>Telescope git_commits<CR>", { desc = "Search commits" })
vim.keymap.set("n", "<Leader>gc", "<cmd>Telescope git_bcommits<CR>", { desc = "Search commits in the buffer" })
vim.keymap.set("n", "<Leader>gB", "<cmd>Telescope git_branches<CR>", { desc = "Search branches" })
vim.keymap.set("n", "<Leader>g?", "<cmd>Telescope git_status<CR>", { desc = "Search gitstatus" })
vim.keymap.set("n", "<Leader>gs", "<cmd>Telescope git_stash<CR>", { desc = "Search stash" })

-- Keymaps from plugin
vim.keymap.set("n", "<Leader>gn", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "Next hunk" })
vim.keymap.set("n", "<Leader>gp", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "Previous hunk" })
vim.keymap.set("n", "<Leader>ga", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<Leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<Leader>gA", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage buffer" })
vim.keymap.set("n", "<Leader>gR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset buffer" })
vim.keymap.set("n", "<Leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<Leader>gi", "<cmd>Gitsigns preview_hunk_inline<CR>", { desc = "Preview hunk inline" })
vim.keymap.set("n", "<Leader>gb", "<cmd>Gitsigns blame<CR>", { desc = "Blame line" })
vim.keymap.set("n", "<Leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff" })
vim.keymap.set("n", "<Leader>gD", "<cmd>Gitsigns diffthis ~<CR>", { desc = "Diff (full document)" })
vim.keymap.set("n", "<Leader>gk", "<cmd>Gitsigns setqflist <CR>", { desc = "Quickfix list" })
vim.keymap.set("n", "<Leader>gK", "<cmd>Gitsigns setqflist all<CR>", { desc = "All Quickfix list" })
vim.keymap.set("n", "<Leader>g<C-b>", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle line blame" })
vim.keymap.set("n", "<Leader>g<C-d>", "<cmd>Gitsigns toggle_word_diff<CR>", { desc = "Toggle word diff" })
-- Text object
vim.keymap.set({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<CR>", { desc = "Select hunk" })

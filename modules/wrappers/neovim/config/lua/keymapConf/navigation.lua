-- <Leader>n: Navigation (window + tab)

-- Window navigation
vim.keymap.set("n", "<Leader>n<Left>", "<cmd>wincmd h<CR>", { desc = "Left window" })
vim.keymap.set("n", "<Leader>n<Down>", "<cmd>wincmd j<CR>", { desc = "Window below" })
vim.keymap.set("n", "<Leader>n<Up>", "<cmd>wincmd k<CR>", { desc = "Window above" })
vim.keymap.set("n", "<Leader>n<Right>", "<cmd>wincmd l<CR>", { desc = "Left window" })
vim.keymap.set("n", "<Leader>nd", "<cmd>close<CR>", { desc = "Close window" })
vim.keymap.set("n", "<Leader>ns", "<cmd>split<CR>", { desc = "Horizontal split window" })
vim.keymap.set("n", "<Leader>nv", "<cmd>vsplit<CR>", { desc = "Vertical split window" })

-- Also have window navigation in all modes
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h", { noremap = true, silent = true, desc = "Left window (term)" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j", { noremap = true, silent = true, desc = "Window below (term)" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k", { noremap = true, silent = true, desc = "Window above (term)" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l", { noremap = true, silent = true, desc = "Right window (term)" })
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Left window" })
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Window below" })
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Window above" })
vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Right window" })

-- Tab navigation
vim.keymap.set("n", "<Leader>nn", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<Leader>nN", "<cmd>tabprev<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<Leader>no", "<cmd>tab split<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<Leader>nO", "<cmd>tabnew<CR>", { desc = "Open new empty tab" })
vim.keymap.set("n", "<Leader>nx", "<cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<Leader>nX", "<cmd>tabonly<CR>", { desc = "Close all other tabs" })

-- Other navigation
vim.keymap.set("n", "<Leader>nj", "<cmd>Telescope jumplist<CR>", { desc = "View jump list entries" })

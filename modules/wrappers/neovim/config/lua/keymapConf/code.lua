-- <Leader>c: Code formatting and linting

-- FN actions
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<F8>", "<cmd>lnext<CR>", { desc = "Next warning" })
vim.keymap.set("n", "<F20>", "<cmd>lprev<CR>", { desc = "Prev warning" })

vim.keymap.set("n", "<Leader>cl", require("lint").try_lint, { desc = "Use [l]inter" })
vim.keymap.set("n", "<Leader>cf", require("conform").format, { desc = "[f]ormat code (conform)" })

-- LSP
vim.keymap.set("n", "<Leader>cn", vim.lsp.buf.rename, { desc = "Re[n]ame symbol" })
vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { desc = "Code [a]ction" })
vim.keymap.set("n", "<Leader>cg", vim.lsp.buf.definition, { desc = "[g]oto definition" })
vim.keymap.set("n", "<Leader>cw", vim.lsp.buf.add_workspace_folder, { desc = "[w]orkspace add folder" })
vim.keymap.set("n", "<Leader>cW", vim.lsp.buf.remove_workspace_folder, { desc = "[W]orkspace remove folder" })
vim.keymap.set("n", "<Leader>cF", vim.lsp.buf.format, { desc = "[F]ormat (lsp)" })

-- Non-leader prefixes (ctrl-k is taken by navigation)
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<C-S-K>", vim.lsp.buf.signature_help, { desc = "Signature help" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto [d]eclaration" })

-- Telescope LSP actions
vim.keymap.set("n", "<Leader>cr", "<cmd>Telescope lsp_references<CR>", { desc = "List LSP references for word" })
vim.keymap.set("n", "<Leader>cc", "<cmd>Telescope lsp_incoming_calls<CR>", { desc = "List LSP incoming [c]alls" })
vim.keymap.set("n", "<Leader>cC", "<cmd>Telescope lsp_outgoing_calls<CR>", { desc = "List LSP outgoing [c]alls" })
vim.keymap.set("n", "<Leader>ci", "<cmd>Telescope lsp_implementations<CR>", { desc = "[i]mplementations for word" })
vim.keymap.set("n", "<Leader>cd", "<cmd>Telescope lsp_definitions<CR>", { desc = "[d]efinitions for word" })
vim.keymap.set("n", "<Leader>ct", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "[t]ype definitions for word" })
vim.keymap.set("n", "<Leader>cs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "List LSP buffer [s]ymbols" })
vim.keymap.set("n", "<Leader>cS", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "List LSP workspace [s]ymbols" })
vim.keymap.set(
  "n",
  "<Leader>c<C-S>",
  "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>",
  { desc = "Dynamically list LSP workspace [s]ymbols" }
)

vim.keymap.set("n", "<Leader>cT", "<cmd>Telescope treesitter<CR>", { desc = "List [T]reesitter queries" })

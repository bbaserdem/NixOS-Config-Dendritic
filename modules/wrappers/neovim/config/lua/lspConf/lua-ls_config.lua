-- Lua language server

local M = {
  "lua_ls",
  for_cat = "lua",
  lsp = {
    settings = {
      Lua = {
        signatureHelp = { enabled = true },
        diagnostics = {
          globals = { "nixInfo", "vim" },
          disable = { "missing-fields" },
        },
      },
    },
  },
}

return M

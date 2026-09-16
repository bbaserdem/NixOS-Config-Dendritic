-- LSP configuration (using lzextras for performance)

nixInfo.lze.load({
  { -- LSP default config
    "nvim-lspconfig",
    auto_enable = true,
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    -- set up our on_attach function once before the spec loads
    before = function(_)
      vim.lsp.config("*", {
        on_attach = function(_, bufnr)
          -- Create a command `:Format` local to the LSP buffer
          vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
            vim.lsp.buf.format()
          end, { desc = "Format current buffer with LSP" })
        end,
      })
    end,
  },
  { import = "lspConf.gopls_config" },
  { import = "lspConf.harper_config" },
  { import = "lspConf.lua-ls_config" },
  { import = "lspConf.nixd_config" },
  { import = "lspConf.rust-analyzer_config" },
  { import = "lspConf.ty_config" },
  { import = "lspConf.typescript-ls_config" },
})

-- Diagnostic signs
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
})

-- Blink cmp configuration

local M = {
  {
    "lspkind.nvim",
    auto_enable = true,
    dep_of = { "blink.cmp" },
    on_require = "lspkind",
    after = function(plugin)
      require("lspkind").init({
        mode = "symbol",
        preset = "default",
      })
    end,
  },
  {
    "colorful-menu.nvim",
    auto_enable = true,
    on_plugin = { "blink.cmp" },
  },
  {
    "blink.cmp",
    auto_enable = true,
    event = "DeferredUIEnter",
    on_require = {
      "blink",
      "blink.cmp",
    },
    after = function(plugin)
      require("blink.cmp").setup({
        keymap = {
          preset = "enter",
        },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true,
            },
          },
          sources = function()
            local type = vim.fn.getcmdtype()
            -- Search forward and backward
            if type == "/" or type == "?" then
              return { "buffer" }
            end
            -- Commands
            if type == ":" or type == "@" then
              return { "cmdline" }
            end
            return {}
          end,
        },
        fuzzy = {
          sorts = {
            "exact",
            -- defaults
            "score",
            "sort_text",
          },
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              treesitter = { "lsp" },
              components = {
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end,
                },
                kind_icon = {
                  text = function(ctx)
                    return require("lspkind").symbol_map[ctx.kind] or ""
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
          },
          ghost_text = {
            enabled = true,
          },
        },
        sources = {
          default = {
            "lsp",
            "path",
            "buffer",
            "omni",
            "snippets",
            "tmux",
            "mkdnflow",
          },
          per_filetype = {
            tex = { inherit_defaults = true, "vimtex" },
            bib = { inherit_defaults = true, "vimtex" },
            latex = { inherit_defaults = true, "vimtex" },
            ["dap-repl"] = { "dap" },
            ["dapui_watches"] = { "dap" },
            ["dapui_hover"] = { "dap" },
            codecompanion = { "codecompanion" },
          },
          providers = {
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
            tmux = {
              module = "blink-cmp-tmux",
              name = "tmux",
              opts = {
                panes = "session",
                capture_history = false,
                triggered_only = false,
                trigger_chars = { "." },
              },
            },
            vimtex = {
              name = "vimtex",
              module = "blink.compat.source",
            },
            dap = {
              name = "dap",
              module = "blink.compat.source",
            },
            mkdnflow = {
              name = "Mkdnflow",
              module = "mkdnflow.completion.blink",
            },
          },
        },
        snippets = {
          preset = "luasnip",
        },
      })
    end,
  },
}

return M

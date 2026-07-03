-- Formatting related plugins

local M = {
  {
    "conform.nvim",
    auto_enable = true,
    event = { "BufWritePre" },
    cmd = {
      "ConformInfo",
      "ConformToggle",
      "ConformToggle!",
    },
    on_require = "conform",
    after = function(plugin)
      require("conform").setup({
        -- Formatters by filetype; this has to be defined here
        formatters_by_ft = {
          lua = {
            "stylua",
          },
          python = {
            "ruff_fix",
            "ruff_format",
            "ruff_organize_imports",
          },
          rust = {
            "rustfmt",
          },
          go = {
            "goimports",
            "gofmt",
          },
          markdown = {
            "prettier",
          },
          nix = {
            "alejandra",
          },
          bib = {
            "bibtex-tidy",
          },
          c = {
            "clang-format",
          },
          tex = {
            "tex-fmt",
          },
        },
        -- Default options
        default_format_opts = {
          lsp_format = "first",
        },
        -- Formatter specific options go into the ftplugin
        -- Format on save
        format_on_save = function(bufnr)
          -- Disable if requested
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          -- Return options otherwise
          return {
            timeout_ms = 1000,
            lsp_format = "fallback",
          }
        end,
      })

      -- Register command to disable conform
      vim.api.nvim_creat_user_command("ConformToggle", function(args)
        if args.bang then
          vim.b.disable_autoformat = not (vim.b.disable_autoformat or false)
          print("Buffer autoformat " .. (vim.b.disable_autoformat and "disabled" or "enabled"))
        else
          vim.g.disable_autoformat = not (vim.g.disable_autoformat or false)
          print("Global autoformat " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
        end
      end, {
        desc = "Toggle autoformat-on-save",
        bang = true,
      })
    end,
  },
  {
    "nvim-lint",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    on_require = "lint",
    after = function(profile)
      require("lint").linters_by_ft = {
        bash = { "bash", "shellcheck" },
        dash = { "dash", "shellcheck" },
        zsh = { "zsh", "shellcheck" },
        dotenv = { "dotenv_linter" },
        yaml = { "yq" },
        python = { "ruff" },
        -- lua = { "luacheck" }, -- Not working for some reason
        latex = { "chktex" },
        -- markdown = { "vale" },
      }

      -- Create a linting auto command
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}

return M

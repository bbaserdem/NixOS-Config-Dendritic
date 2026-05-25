-- CodeCompanion config

local M = {
  "codecompanion.nvim",
  auto_enable = true,
  on_require = "codecompanion",
  cmd = {
    "CodeCompanion",
    "CodeCompanionCmd",
    "CodeCompanionChat",
  },
  after = function(plugin)
    require("codecompanion").setup({
      interactions = {
        chat = {
          adapter = "opencode",
        },
        inline = {
          adapter = "openai",
        },
        cmd = {
          adapter = "openai",
        },
        cli = {
          agent = "opencode",
          ogents = {
            opencode = {
              cmd = "opencode",
              args = {},
              description = "OpenCode CLI",
              provider = "terminal",
            },
            forge = {
              cmd = "forge",
              args = {},
              description = "ForgeCode CLI",
              provider = "terminal",
            },
            droid = {
              cmd = "droid",
              args = {},
              description = "Factory.ai Droid CLI",
              provider = "terminal",
            },
            claude_code = {
              cmd = "claude",
              args = {},
              description = "Claude Code CLI",
              provider = "terminal",
            },
            codex = {
              cmd = "codex",
              args = {},
              description = "Codex CLI",
              provider = "terminal",
            },
          },
        },
      },
      adapters = {
        acp = {
          opts = {
            show_presets = true,
          },
        },
      },
    })
  end,
}

return M

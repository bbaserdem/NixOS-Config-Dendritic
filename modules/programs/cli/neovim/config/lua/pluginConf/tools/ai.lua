-- AI tooling to work with neovim

local M = {
  {
    "codecompanion.nvim",
    auto_enable = true,
    on_require = "codecompanion",
    cmd = {
      "CodeCompanion",
      "CodeCompanionCmd",
      "CodeCompanionChat",
    },
    after = function(plugin)
      require("codecompanion").setup({})
    end,
  },
  { -- Git status signs in the num column
    "claudecode.nvim",
    auto_enable = true,
    on_require = "claudecode",
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    after = function(plugin)
      require("claudecode").setup({
        git_repo_cwd = true,
        terminal = {
          -- Need this so snacks terminal doesn't get used
          provider = "native",
        },
      })
    end,
  },
  { -- Companion to claudecode nvim
    "claude-fzf.nvim",
    auto_enable = true,
    on_require = "claude-fzf",
    cmd = {
      "ClaudeFzf",
      "ClaudeFzfFiles",
      "ClaudeFzfGrep",
      "ClaudeFzfBuffers",
      "ClaudeFzfGitFiles",
      "ClaudeFzfDirectory",
    },
    after = function(plugin)
      require("claude-fzf").setup({
        batch_size = 10,
        logging = {
          level = "WARN",
        },
      })
    end,
  },
  { -- Req for claude-fzf.nvim
    "fzf-lua",
    auto_enable = true,
    dep_of = {
      "claude-fzf.nvim",
    },
    on_require = "fzf-lua",
    after = function(plugin)
      require("fzf-lua").setup({})
    end,
  },
}

return M

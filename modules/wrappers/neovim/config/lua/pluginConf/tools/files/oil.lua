-- Oil nvim; replacement for netrc

local M = {
  {
    "oil-git-status.nvim",
    auto_enable = true,
    on_require = "oil-git-status",
    on_plugin = "oil.nvim",
  },
  {
    "oil.nvim",
    auto_enable = true,
    lazy = false,
    after = function(plugin)
      require("oil").setup({
        default_file_explorer = true,
        columns = {
          "icon",
          -- 'permissions',
          "size",
          -- 'mtime',
        },
        -- Buffer-local options to use for oil buffers
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        -- Window-local options to use for oil buffers
        win_options = {
          wrap = false,
          signcolumn = "yes:2",
          cursorcolumn = false,
          foldcolumn = "0",
          spell = false,
          list = false,
          conceallevel = 3,
          concealcursor = "nvic",
        },
        -- Trashing
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        prompt_save_on_select_new_entry = true,
        lsp_file_methods = {
          enabled = true,
          autosave_changes = false,
        },
        constrain_cursor = "editable",
        -- Do filesystem changes
        watch_for_changes = true,
        -- View options
        view_options = {
          natural_order = false,
        },
      })
      -- Oil git signs config
      require("oil-git-status").setup({
        index = {
          ["!"] = "!", -- Ignored
          ["?"] = "?", -- Untracked
          ["A"] = "A", -- Added
          ["C"] = "C", -- Copied
          ["D"] = "D", -- Deleted
          ["M"] = "M", -- Modified
          ["R"] = "R", -- Renamed
          ["T"] = "T", -- Type changed
          ["U"] = "U", -- Unmerged
          [" "] = " ", -- Unmodified
        },
        working_tree = {
          ["!"] = "!", -- Ignored
          ["?"] = "?", -- Untracked
          ["A"] = "A", -- Added
          ["C"] = "C", -- Copied
          ["D"] = "D", -- Deleted
          ["M"] = "M", -- Modified
          ["R"] = "R", -- Renamed
          ["T"] = "T", -- Type changed
          ["U"] = "U", -- Unmerged
          [" "] = " ", -- Unmodified
        },
      })
    end,
  },
}

return M

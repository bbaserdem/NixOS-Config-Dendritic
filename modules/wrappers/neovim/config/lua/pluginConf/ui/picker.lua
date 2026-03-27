-- Picker menu using telescope

local M = {
  {
    "telescope.nvim",
    auto_enable = true,
    dep_of = {
      "urlview.nvim",
      "neogit",
    },
    on_require = {
      "telescope",
      "telescope.builtin",
    },
    cmd = { "Telescope" },
    after = function(plugin)
      local telescope = require("telescope")

      telescope.setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      -- Load the extensions
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")

      -- Optional extensions
      local dap_status, dap = pcall(require, "dap")
      if dap_status then
        telescope.load_extension("dap")
      end
      local manix_status, manix = pcall(require, "telescope-manix")
      if manix_status then
        telescope.load_extension("manix")
      end
    end,
  },
  -- Extensions
  {
    "telescope-ui-select.nvim",
    auto_enable = true,
    dep_of = {
      "telescope.nvim",
    },
  },
  {
    "telescope-fzf-native.nvim",
    dep_of = {
      "telescope.nvim",
      "neogit",
    },
    auto_enable = true,
  },
  {
    "telescope-dap.nvim",
    dep_of = {
      "telescope.nvim",
    },
    auto_enable = true,
  },
  {
    "telescope-manix",
    dep_of = {
      "telescope.nvim",
    },
    auto_enable = true,
  },
}

return M

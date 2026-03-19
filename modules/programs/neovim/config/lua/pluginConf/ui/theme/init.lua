-- Theme-ing related settings

local M = {
  { import = "pluginConf.ui.theme.catppuccin" },
  { import = "pluginConf.ui.theme.cyberdream" },
  { import = "pluginConf.ui.theme.eink" },
  { import = "pluginConf.ui.theme.gruvbox" },
  { import = "pluginConf.ui.theme.gruvboxMaterial" },
  { import = "pluginConf.ui.theme.kanagawa" },
  { import = "pluginConf.ui.theme.material" },
  { import = "pluginConf.ui.theme.melange" },
  { import = "pluginConf.ui.theme.nightfox" },
  { import = "pluginConf.ui.theme.onedark" },

  -- Web-Devicons
  {
    "nvim-web-devicons",
    auto_enable = true,
    -- We are needed by non-lazy loaded things
    lazy = false,
    priority = 10,
    dep_of = {
      "oil.nvim",
      "neo-tree.nvim",
      "fzf-lua",
      "hunk.nvim",
    },
    after = function(plugin)
      require("nvim-web-devicons").setup({
        color_icons = true,
      })
    end,
  },
}

return M

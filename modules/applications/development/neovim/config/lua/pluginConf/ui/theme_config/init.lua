-- Theme-ing related settings

local M = {
  { import = "pluginConf.ui.theme_config.catppuccin_config" },
  { import = "pluginConf.ui.theme_config.cyberdream_config" },
  { import = "pluginConf.ui.theme_config.eink_config" },
  { import = "pluginConf.ui.theme_config.gruvbox_config" },
  { import = "pluginConf.ui.theme_config.gruvboxMaterial_config" },
  { import = "pluginConf.ui.theme_config.kanagawa_config" },
  { import = "pluginConf.ui.theme_config.material_config" },
  { import = "pluginConf.ui.theme_config.melange_config" },
  { import = "pluginConf.ui.theme_config.nightfox_config" },
  { import = "pluginConf.ui.theme_config.onedark_config" },

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

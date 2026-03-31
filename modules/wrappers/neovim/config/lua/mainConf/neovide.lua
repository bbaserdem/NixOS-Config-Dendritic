-- Set up neovide

-- Define fallback fonts, we don't have any of the builtins
vim.opt.guifont = "JetBrains_Mono,Symbols_Nerd_Font_Mono:h14"

-- Neovide will be set with only font settings in config.toml.
-- That's due to having a complex override that's not possible with opt.guifont
-- Rest of the config is done here
vim.g.neovide_opacity = 0.8
vim.g.neovide_text_gamma = 0.8
vim.g.neovide_text_contrast = 0.5
vim.g.neovide_window_blurred = true
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 4.0
vim.g.neovide_progress_bar_enabled = true
vim.g.neovide_theme = "auto"
vim.g.neovide_cursor_vfx_mode = { "railgun", "sonicboom" }

-- Yazi Lua config bundled by nix-wrapper-modules.

require("full-border"):setup({
  type = ui.Border.ROUNDED,
})

require("git"):setup({
  order = 1500,
})

require("starship"):setup()

require("smart-enter"):setup({
  open_multi = false,
})

require("projects"):setup({})

local ok_mactag, mactag = pcall(require, "mactag")
if ok_mactag then
  mactag:setup({
    keys = {
      r = "Red",
      o = "Orange",
      y = "Yellow",
      g = "Green",
      b = "Blue",
      p = "Purple",
    },
    colors = {
      Red = "#ee7b70",
      Orange = "#f5bd5c",
      Yellow = "#fbe764",
      Green = "#91fc87",
      Blue = "#5fa3f8",
      Purple = "#cb88f8",
    },
    order = 500,
  })
end

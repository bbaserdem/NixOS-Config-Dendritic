-- Lean plugin config

local M = {
  {
    "lean.nvim",
    auto_enable = true,
    cmd = {
      "LeanGoal",
      "LeanTermGoal",
      "LeanInfoviewToggle",
      "LeanInfoviewViewOptions",
      "LeanInfoviewAddPin",
      "LeanInfoviewClearPins",
      "LeanInfoviewSetDiffPin",
      "LeanInfoviewClearDiffPin",
      "LeanInfoviewToggleAutoDiffPin",
      "LeanInfoviewToggleNoClearAutoDiffPin",
      "LeanInfoviewEnableWidgets",
      "LeanInfoviewDisableWidgets",
      "LeanGotoInfoview",
      "LeanAbbreviationsReverseLookup",
      "LeanInfoviewPinTogglePause",
      "LeanRestartFile",
    },
    ft = "lean",
    on_require = "lean",
    after = function(plugin)
      require("lean").setup({
        -- Mappings are localleader mappings
        mappings = true,
        lsp = {
          init_options = {
            -- ms delay since edit before elaboration begins
            editDelay = 500,
            hasWidgets = true,
          },
        },
        abbreviations = {
          enable = true,
        },
      })
    end,
  },
}

return M

-- Indent lines to render indentation levels

local M = {
  enabled = true,
  char = "│",
  only_scope = false,
  only_current = false,
  scope = {
    enabled = true,
    priority = 200,
    char = "┇",
    underline = true,
    only_current = false,
    hl = "SnacksIndentScope",
  },
  chunk = {
    enabled = true,
    only_current = false,
    priority = 200,
    hl = "SnacksIndentChunk",
    char = {
      corner_top = "┏",
      corner_bottom = "┗",
      horizontal = "━",
      vertical = "┃",
      arrow = "⯈",
    },
  },
}

return M

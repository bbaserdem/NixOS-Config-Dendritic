-------------------------------------------------
-- Shell files behavior
-------------------------------------------------
vim.bo.expandtab = true -- Turn tab into spaces
vim.bo.tabstop = 2 -- size of a hard tabstop (ts).
vim.bo.shiftwidth = 2 -- size of an indentation (sw).
vim.bo.softtabstop = 2 -- number of spaces a <Tab> counts for. When 0, feature is off (sts).

-- Configure shfmt
local cf_status, cf = pcall(require, "conform")
if cf_status then
  cf.formatters.shfmt = {
    append_args = function(_, ctx)
      return {
        -- Set indentation spaces
        "-i",
        tostring(vim.bo[ctx.buf].shiftwidth),
        -- Switch case also indented
        "-ci",
      }
    end,
  }
end

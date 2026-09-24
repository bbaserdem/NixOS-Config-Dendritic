-------------------------------------------------
-- Lua files behavior
-------------------------------------------------
-- Custom tablength; 2

-- Using vim.bo so that these are only established for the buffer
vim.bo.expandtab = true -- Turn tab into spaces
vim.bo.shiftwidth = 2 -- size of an indentation (sw).
vim.bo.tabstop = 2 -- size of a hard tabstop (ts).
vim.bo.softtabstop = 2 -- number of spaces a <Tab> counts for.

-- Configure stylua
local cf_status, cf = pcall(require, "conform")
if cf_status then
  cf.formatters.stylua = {
    prepend_args = function(_, ctx)
      return {
        "--indent-type",
        "Spaces",
        "--indent-width",
        tostring(vim.bo[ctx.buf].shiftwidth),
      }
    end,
  }
end

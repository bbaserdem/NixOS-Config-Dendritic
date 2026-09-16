-- Latex keybinds

-- By default, vimtex doesn't have shortcut descriptions due to being in vimscript
-- We use autocmd and which-key to add these descriptions, and icons
local augroup = vim.api.nvim_create_augroup("vimtexConfig", {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  group = augroup,
  callback = function(event)
    -- Register icons to which-key if present
    local wk_status, wk = pcall(require, "which-key")
    if wk_status then
      wk.add({
        buffer = event.buf, -- e.g. ev.buf or similar
        {
          "<localleader>l",
          group = "VimTeX",
          icon = { icon = " ", color = "green" },
          mode = "nx",
        },
        {
          mode = "n",
          {
            "<localleader>ll",
            desc = "Compile",
            icon = { icon = " ", color = "green" },
          },
          {
            "<localleader>lL",
            desc = "Compile selected",
            icon = { icon = " ", color = "green" },
            mode = "nx",
          },
          {
            "<localleader>li",
            desc = "Information",
            icon = { icon = " ", color = "purple" },
          },
          {
            "<localleader>lI",
            desc = "Full information",
            icon = { icon = "󰙎 ", color = "purple" },
          },
          {
            "<localleader>lt",
            desc = "Table of Contents",
            icon = { icon = "󰠶 ", color = "purple" },
          },
          {
            "<localleader>lT",
            desc = "Toggle table of Contents",
            icon = { icon = "󰠶 ", color = "purple" },
          },
          {
            "<localleader>lq",
            desc = "Log",
            icon = { icon = " ", color = "purple" },
          },
          {
            "<localleader>lv",
            desc = "View",
            icon = { icon = " ", color = "green" },
          },
          {
            "<localleader>lr",
            desc = "Reverse search",
            icon = { icon = " ", color = "purple" },
          },
          {
            "<localleader>lk",
            desc = "Stop",
            icon = { icon = " ", color = "red" },
          },
          {
            "<localleader>lK",
            desc = "Stop all",
            icon = { icon = "󰓛 ", color = "red" },
          },
          {
            "<localleader>le",
            desc = "Errors",
            icon = { icon = " ", color = "red" },
          },
          {
            "<localleader>lo",
            desc = "Compile output",
            icon = { icon = " ", color = "purple" },
          },
          {
            "<localleader>lg",
            desc = "Status",
            icon = { icon = "󱖫 ", color = "purple" },
          },
          {
            "<localleader>lG",
            desc = "Full status",
            icon = { icon = "󱖫 ", color = "purple" },
          },
          {
            "<localleader>lc",
            desc = "Clean",
            icon = { icon = "󰃢 ", color = "orange" },
          },
          {
            "<localleader>lh",
            desc = "Clear all cache",
            icon = { icon = "󰃢 ", color = "grey" },
          },
          {
            "<localleader>lC",
            desc = "Full clean",
            icon = { icon = "󰃢 ", color = "red" },
          },
          {
            "<localleader>lx",
            desc = "Reload",
            icon = { icon = "󰑓 ", color = "green" },
          },
          {
            "<localleader>lX",
            desc = "Reload state",
            icon = { icon = "󰑓 ", color = "cyan" },
          },
          {
            "<localleader>lm",
            desc = "Input mappings",
            icon = { icon = " ", color = "purple" },
          },
          {
            "<localleader>ls",
            desc = "Toggle main",
            icon = { icon = "󱪚 ", color = "green" },
          },
          {
            "<localleader>la",
            desc = "Context menu",
            icon = { icon = "󰮫 ", color = "purple" },
          },
          {
            "ds",
            group = "+surrounding",
            icon = { icon = "󰗅 ", color = "green" },
          },
          {
            "dse",
            desc = "environment",
            icon = { icon = " ", color = "red" },
          },
          {
            "dsc",
            desc = "command",
            icon = { icon = " ", color = "red" },
          },
          {
            "ds$",
            desc = "math",
            icon = { icon = "󰿈 ", color = "red" },
          },
          {
            "dsd",
            desc = "delimiter",
            icon = { icon = "󰅩 ", color = "red" },
          },
          {
            "cs",
            group = "+surrounding",
            icon = { icon = "󰗅 ", color = "green" },
          },
          {
            "cse",
            desc = "environment",
            icon = { icon = " ", color = "blue" },
          },
          {
            "csc",
            desc = "command",
            icon = { icon = " ", color = "blue" },
          },
          {
            "cs$",
            desc = "math environment",
            icon = { icon = "󰿈 ", color = "blue" },
          },
          {
            "csd",
            desc = "delimiter",
            icon = { icon = "󰅩 ", color = "blue" },
          },
          {
            "ts",
            group = "+surrounding",
            icon = { icon = "󰗅 ", color = "green" },
            mode = "nx",
          },
          {
            "tsf",
            desc = "fraction",
            icon = { icon = "󱦒 ", color = "yellow" },
            mode = "nx",
          },
          {
            "tsc",
            desc = "command",
            icon = { icon = " ", color = "yellow" },
          },
          {
            "tse",
            desc = "environment",
            icon = { icon = " ", color = "yellow" },
          },
          {
            "ts$",
            desc = "math environment",
            icon = { icon = "󰿈 ", color = "yellow" },
          },
          {
            "tsb",
            desc = "break",
            icon = { icon = "󰿈 ", color = "yellow" },
          },
          {
            "<F6>",
            desc = "Surround line with environment",
            icon = { icon = " ", color = "purple" },
          },
          {
            "<F6>",
            desc = "Surround selection with environment",
            icon = { icon = " ", color = "purple" },
            mode = "x",
          },
          {
            "tsd",
            desc = "delimiter",
            icon = { icon = "󰅩 ", color = "yellow" },
            mode = "nx",
          },
          {
            "tsD",
            desc = "reverse surrounding delimiter",
            icon = { icon = "󰅩 ", color = "yellow" },
            mode = "nx",
          },
          {
            "<F7>",
            desc = "Create command",
            icon = { icon = "󰅩 ", color = "green" },
            mode = "nxi",
          },
          {
            "]]",
            desc = "Close delimiter",
            icon = { icon = "󰅩 ", color = "green" },
            mode = "i",
          },
          {
            "<F8>",
            desc = "Add \\left and \\right",
            icon = { icon = "󰅩 ", color = "green" },
            mode = "n",
          },
        },
        {
          mode = "xo",
          {
            "ac",
            desc = "command",
            icon = { icon = " ", color = "orange" },
          },
          {
            "ic",
            desc = "command",
            icon = { icon = " ", color = "orange" },
          },
          {
            "ad",
            desc = "delimiter",
            icon = { icon = "󰅩 ", color = "orange" },
          },
          {
            "id",
            desc = "delimiter",
            icon = { icon = "󰅩 ", color = "orange" },
          },
          {
            "ae",
            desc = "environment",
            icon = { icon = " ", color = "orange" },
          },
          {
            "ie",
            desc = "environment",
            icon = { icon = " ", color = "orange" },
          },
          {
            "a$",
            desc = "math",
            icon = { icon = "󰿈 ", color = "orange" },
          },
          {
            "i$",
            desc = "math",
            icon = { icon = "󰿈 ", color = "orange" },
          },
          {
            "aP",
            desc = "section",
            icon = { icon = "󰚟 ", color = "orange" },
          },
          {
            "iP",
            desc = "section",
            icon = { icon = "󰚟 ", color = "orange" },
          },
          {
            "am",
            desc = "item",
            icon = { icon = " ", color = "orange" },
          },
          {
            "im",
            desc = "item",
            icon = { icon = " ", color = "orange" },
          },
        },
        {
          mode = "nxo",
          {
            "%",
            desc = "Matching pair",
            icon = { icon = "󰐱 ", color = "cyan" },
          },
          {
            "]]",
            desc = "Next end of a section",
            icon = { icon = "󰚟 ", color = "cyan" },
          },
          {
            "][",
            desc = "Next beginning of a section",
            icon = { icon = "󰚟 ", color = "cyan" },
          },
          {
            "[]",
            desc = "Previous end of a section",
            icon = { icon = "󰚟 ", color = "cyan" },
          },
          {
            "[[",
            desc = "Previous beginning of a section",
            icon = { icon = "󰚟 ", color = "cyan" },
          },
          {
            "]m",
            desc = "Next start of an environment",
            icon = { icon = " ", color = "cyan" },
          },
          {
            "]M",
            desc = "Next end of an environment",
            icon = { icon = " ", color = "cyan" },
          },
          {
            "[m",
            desc = "Previous start of an environment",
            icon = { icon = " ", color = "cyan" },
          },
          {
            "[M",
            desc = "Previous end of an environment",
            icon = { icon = " ", color = "cyan" },
          },
          {
            "]n",
            desc = "Next start of math",
            icon = { icon = "󰿈 ", color = "cyan" },
          },
          {
            "]N",
            desc = "Next end of math",
            icon = { icon = "󰿈 ", color = "cyan" },
          },
          {
            "[n",
            desc = "Previous start of math",
            icon = { icon = "󰿈 ", color = "cyan" },
          },
          {
            "[N",
            desc = "Previous end of math",
            icon = { icon = "󰿈 ", color = "cyan" },
          },
          {
            "]r",
            desc = "Next start of frame environment",
            icon = { icon = "󰹉 ", color = "cyan" },
          },
          {
            "]R",
            desc = "Next end of frame environment",
            icon = { icon = "󰹉 ", color = "cyan" },
          },
          {
            "[r",
            desc = "Previous start of frame environment",
            icon = { icon = "󰹉 ", color = "cyan" },
          },
          {
            "[R",
            desc = "Previous end of frame environment",
            icon = { icon = "󰹉 ", color = "cyan" },
          },
          {
            "]/",
            desc = "Next start of a comment",
            icon = { icon = " ", color = "cyan" },
          },
          {
            "]*",
            desc = "Next end of a comment",
            icon = { icon = " ", color = "cyan" },
          },
          {
            "[/",
            desc = "Previous start of a comment",
            icon = { icon = " ", color = "cyan" },
          },
          {
            "[*",
            desc = "Previous end of a comment",
            icon = { icon = " ", color = "cyan" },
          },
        },
        {
          "K",
          desc = "See package documentation",
          icon = { icon = "󱔗 ", color = "azure" },
        },
      })
    end
  end,
})

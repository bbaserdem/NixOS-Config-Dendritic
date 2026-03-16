--[[
-- NeoVim config entry point
--]]

-- NOTE: Welcome to your neovim configuration!
vim.loader.enable() -- <- bytecode caching

-- NIX: Configuration for nix-wrapper-modules context
-- In general, we expect this neovim config to use nix-wrapper-modules for package management
-- TODO: We will setup catPaq and mason as fallback.

-- Set up a global in a way that also handles non-nix compat
do
  local ok
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)

  -- nixInfo calls will just default to the fallback value, even if we are not nix
  if not ok then
    package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
      __call = function(_, default)
        return default
      end,
    })
    _G.nixInfo = require(vim.g.nix_info_plugin_name)
    -- If you always use the fetcher function to fetch nix values,
    -- rather than indexing into the tables directly,
    -- it will use the value you specified as the default
    -- TODO: for non-nix compat, vim.pack.add in another file and require here.
  end

  -- check if we are nix
  nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil

  -- load lze
  ---@module 'lzextras'
  ---@type lzextras | lze
  nixInfo.lze = setmetatable(require("lze"), getmetatable(require("lzextras")))

  -- function to get the plugin path from nix
  function nixInfo.get_nix_plugin_path(name)
    return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
  end
end

-- Register handlers for lze
-- The auto_enable field is convenient to have the plugin only register when it's spec is enabled
-- Default to not doing anything when not in nix
-- The for_cat field is convenient to have lsp's only register when spec is enabled
-- It's useful for configuring lsp's using lzextras spec
nixInfo.lze.register_handlers({
  {
    -- adds an `auto_enable` field to lze specs
    -- if true, will disable it if not installed by nix.
    -- if string, will disable if that name was not installed by nix.
    -- if a table of strings, it will disable if any were not.
    spec_field = "auto_enable",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        if type(plugin.auto_enable) == "table" then
          for _, name in pairs(plugin.auto_enable) do
            if not nixInfo.get_nix_plugin_path(name) then
              plugin.enabled = false
              break
            end
          end
        elseif type(plugin.auto_enable) == "string" then
          if not nixInfo.get_nix_plugin_path(plugin.auto_enable) then
            plugin.enabled = false
          end
        elseif type(plugin.auto_enable) == "boolean" and plugin.auto_enable then
          if not nixInfo.get_nix_plugin_path(plugin.name) then
            plugin.enabled = false
          end
        end
      end
      return plugin
    end,
  },
  {
    -- we made an options.settings.cats with the value of enable for our top level specs
    -- give for_cat = "name" to disable if that one is not enabled
    -- For non-nix, it doesn't touch the status
    spec_field = "for_cat",
    set_lazy = false,
    modify = function(plugin)
      if vim.g.nix_info_plugin_name then
        if type(plugin.for_cat) == "string" then
          plugin.enabled = nixInfo(false, "settings", "cats", plugin.for_cat)
        end
      end
      return plugin
    end,
  },
  -- From lzextras. This one makes it so that
  -- you can set up lsps within lze specs,
  -- and trigger lspconfig setup hooks only on the correct filetypes
  -- It is (unfortunately) important that it be registered after the above 2,
  -- as it also relies on the modify hook, and the value of enabled at that point
  nixInfo.lze.lsp,
})

-- NOTE: This config uses lzextras.lsp handler https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- Because we have the paths, we can set a more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- If you do provide a filetype, this will never be called.
nixInfo.lze.h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixInfo.get_nix_plugin_path("nvim-lspconfig")
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    return (ok and cfg or {}).filetypes or {}
  else
    -- the less performant thing we are trying to avoid at startup
    return (vim.lsp.config[name] or {}).filetypes or {}
  end
end)

-- We move on to the main entry point for configuration
require("mainConf")

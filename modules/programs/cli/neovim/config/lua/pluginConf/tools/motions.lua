-- Movement extensions

local M = {
  {
    "mini.ai",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    on_require = "mini.ai",
    after = function(plugin)
      -- Need to activate all the individual plugins separately
      require("mini.ai").setup()
    end,
  },
  {
    "mini.align",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    on_require = "mini.align",
    after = function(plugin)
      -- Need to activate all the individual plugins separately
      require("mini.align").setup()
    end,
  },
  {
    "mini.comment",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    on_require = "mini.comment",
    after = function(plugin)
      -- Need to activate all the individual plugins separately
      require("mini.comment").setup()
    end,
  },
  {
    "mini.move",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    on_require = "mini.move",
    after = function(plugin)
      -- Need to activate all the individual plugins separately
      require("mini.move").setup()
    end,
  },
  {
    "mini.pairs",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    on_require = "mini.pairs",
    after = function(plugin)
      -- Need to activate all the individual plugins separately
      require("mini.pairs").setup()
    end,
  },
  {
    "mini.splitjoin",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    on_require = "mini.splitjoin",
    after = function(plugin)
      -- Need to activate all the individual plugins separately
      require("mini.splitjoin").setup()
    end,
  },
  {
    "mini.surround",
    auto_enable = true,
    event = { "DeferredUIEnter" },
    on_require = "mini.surround",
    after = function(plugin)
      -- Need to activate all the individual plugins separately
      require("mini.surround").setup()
    end,
  },
}

return M

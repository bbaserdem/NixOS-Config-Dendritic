-- Nix language server

local M = {
  "nixd",
  for_cat = "nix",
  lsp = {
    settings = {
      nixd = {
        nixpkgs = {
          expr = [[import <nixpkgs> {}]],
        },
        options = {},
        formatting = {
          command = { "nix", "fmt" },
          diagnostic = {
            suppress = {
              "sema-escaping-with",
            },
          },
        },
      },
    },
  },
}

return M

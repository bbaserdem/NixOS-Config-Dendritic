# Flake-Parts module for neovim config wrapper
{inputs, ...}: {
  flake = {
    # Flake-Parts configuration for neovim wrapper

    # The neovim nightly flake
    flake-file = {
      # Nightly build
      neovim-nightly-overlay = {
        url = "githubh:nix-community/neovim-nightly-overlay";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    # Auto-pull neovim plugins from flake inputs with the prefix
    wrappers.neovim = {
      wlib,
      lib,
      config,
      ...
    }: {
      options = {
        # Helper function to scrawl all neovim-plugin- prefixed flake inputs
        nvim-lib.pluginsFromPrefix = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
          default = prefix: inputs:
            lib.pipe inputs [
              builtins.attrNames
              (builtins.filter (s: lib.hasPrefix prefix s))
              (map (
                input: let
                  name = lib.removePrefix prefix input;
                in {
                  inherit name;
                  value = config.nvim-lib.mkPlugin name inputs.${input};
                }
              ))
              builtins.listToAttrs
            ];
        };

        # Makes plugins autobuilt from flake inputs available with
        # `config.nvim-lib.neovimPlugins.<name_without_prefix>`
        nvim-lib.neovimPlugins = lib.mkOption {
          readOnly = true;
          type = lib.types.attrsOf wlib.types.stringable;
          default = config.nvim-lib.pluginsFromPrefix "neovim-plugin-" inputs;
        };
      };
    };
  };
}

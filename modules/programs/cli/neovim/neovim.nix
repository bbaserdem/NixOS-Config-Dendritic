# Neovim configuration wrapper
# Uses nix-wrapper-modules to package multiple neovim derivations with different setup
{inputs, ...}: {
  flake = {
    wrappers.neovim = {
      pkgs,
      wlib,
      lib,
      config,
      ...
    }: {
      # Load the wrapper module for neovim
      imports = [
        wlib.wrapperModules.neovim
      ];

      options = {
        # Common options defined for all setups

        settings = {
          # Define options that will be used by instances of neovim
          # Available with;
          # require(vim.g.nix_info_plugin_name)(<fallback>, "settings",...) == value

          # Whether to enable spelling or not
          spelling = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };

          # Colorscheme settings
          colorscheme = {
            dark = lib.mkOption {
              type = lib.types.str;
              default = "terafox";
            };
            light = lib.mkOption {
              type = lib.types.str;
              default = "dawnfox";
            };
            translucent = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
        };
      };

      # Configuring neovim defaults
      config = {
        settings = {
          # Use the neovim config from the config subdirectory
          config_directory = ./config;

          # Name the internal info plugin
          info_plugin_name = "nix-info";
        };

        # Collect enable status of specs here
        info.cats = builtins.mapAttrs (_: v: v.enable) config.specs;

        # By default, the extraPackages is a config option to put executable to path
        # We want to actually collect these from the (enabled) specs themselves
        # So we have each spec define both plugin-dependencies, and runtime dependencies
        specMods = {...}: {
          options.extraPackages = lib.mkOption {
            type = lib.types.listOf wlib.types.stringable;
            default = [];
            description = "a extraPackages spec field to put packages to suffix to the PATH";
          };
        };
        extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [])) [];

        # Spects, similar to nixCats categories
        specs = {
          # Specs; these are dependencies + plugins; ~ nixCats categories

          # Base plugins; list of plugins that should always exist
          system = {
            # These plugins will default to no lazy loading
            lazy = true;
            data = with pkgs.vimPlugins; [
              {
                data = lze;
                lazy = false;
              }
              {
                data = lzextras;
                lazy = false;
              }
              {
                data = nvim-lspconfig;
                lazy = false;
              }
              plenary-nvim
              nui-nvim
              nvim-nio
              mini-base16
            ];
          };
        };
      };
    };
  };
}

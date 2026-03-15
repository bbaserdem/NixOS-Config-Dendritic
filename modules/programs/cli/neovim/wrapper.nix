# Neovim configuration wrapper
# Uses nix-wrapper-modules to package multiple neovim derivations with different setup
{inputs, ...}: {
  # The module for configuring neovim

  # Pull the neovim nightly flake
  flake-file.inputs = {
    # Nightly build
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # The wrapper
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

      # Additional options
      options = {
        # Helper function to scrawl all prefixed flake inputs
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

        settings = {
          # Define options that will be used by instances of neovim
          # Available with;
          # require(vim.g.nix_info_plugin_name)(<fallback>, "settings",...) == value

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

          # A minimal flag to disable almost all plugins
          minimal = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };

      config = {
        # Configuring the wrapper settings

        # Use neovim nightly as package
        package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

        settings = {
          # Use the neovim config from the config subdirectory
          config_directory = ./config;

          # Name the internal info plugin
          info_plugin_name = "nix-info";
        };

        # Collect the list of enabled categories in a table
        info.cats = builtins.mapAttrs (_: v: v.enable) config.specs;

        # Spec modifiers
        specMods = {parentSpec, ...}: {
          # Add extraPackages option to collect runtime dependencies
          options.extraPackages = lib.mkOption {
            type = lib.types.listOf wlib.types.stringable;
            default = [];
            description = "a extraPackages spec field to put packages to suffix to the PATH";
          };

          # If we are minimal, then disable all specs
          config.enable = lib.mkIf config.settings.minimal (lib.mkOverride 1400 (parentSpec.enable or false));
        };

        # By default, the extraPackages is a config option to put executable to path
        # We want to actually collect these from the (enabled) specs themselves
        # So we have each spec define both plugin-dependencies, and runtime dependencies
        extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [])) [];
      };
    };
  };
}

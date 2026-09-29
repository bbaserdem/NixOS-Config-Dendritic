# Flake-Parts module for neovim config wrapper
{config, ...}: {
  flake = {
    # Flake-Parts configuration for neovim wrapper
    # The general wrappers config is set in the flake config
    # In general, the module does
    # - the wrapper module is available as outputs.wrapper.neovim
    # - package from wrapper is available as outputs.packages.<system>.neovim
    # - the importable module is available in outputs.wrapperModules.neovim

    # TODO: Remove after den migration
    # Config is available from config.wrappers.neovim in each context after this

    # Nixos and nix-darwin module
    modules.generic.neovim = {...}: {
      # Import the module from the wrapper
      imports = [
        config.flake.wrappers.neovim.install
      ];
    };

    # Home-manager module
    modules.homeManager.neovim = {...}: {
      # Import the module from the wrapper
      imports = [
        config.flake.wrappers.neovim.install
      ];
    };
  };
}

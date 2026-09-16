# Flake-Parts module for neovim config wrapper
{
  inputs,
  config,
  ...
}: {
  flake = {
    # Flake-Parts configuration for neovim wrapper
    # The general wrappers config is set in the flake config
    # In general, the module does
    # - the wrapper module is available as outputs.wrapper.neovim
    # - package from wrapper is available as outputs.packages.<system>.neovim
    # - the importable module is available in outputs.wrapperModules.neovim

    # Map the module; it's a generic module for all contexts
    flake.modules.generic.neovim-wrapper = {...}: {
      key = "neovim-wrapper#generic";
      imports = [
        inputs.self.wrappers.neovim.install
      ];
    };
    flake.modules.homeManager.neovim-wrapper = {...}: {
      key = "neovim-wrapper#homeManager";
      imports = [
        inputs.self.wrappers.neovim.install
      ];
    };

    # TODO: Remove after den migration
    # Config is available from config.wrappers.neovim in each context after this

    # Nixos and nix-darwin module
    flake.modules.generic.neovim = {...}: {
      # Import the module from the wrapper
      imports = [
        config.flake.wrappers.neovim.install
      ];
    };

    # Home-manager module
    flake.modules.homeManager.neovim = {...}: {
      # Import the module from the wrapper
      imports = [
        config.flake.wrappers.neovim.install
      ];
    };
  };
}

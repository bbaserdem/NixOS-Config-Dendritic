# Flake-Parts module for neovim config wrapper
{inputs, ...}: {
  flake = {
    # Flake-Parts configuration for neovim wrapper
    # The general wrappers config is set in the flake config
    # In general, the module does
    # - the wrapper module is available as outputs.wrapper.neovim
    # - package from wrapper is available as outputs.packages.<system>.neovim
    # - the importable module is available in outputs.wrapperModules.neovim

    # The flake modules for each system
    modules = {
      # Config is available from config.wrappers.neovim in each context after this

      # Nixos and nix-darwin module
      generic.neovim = {...}: {
        # Import the module from the wrapper
        imports = [
          # The modules are exported in outputs.wrapperModules
          (inputs.wrappers.lib.mkInstallModule {
            # Location to install
            loc = ["environment" "systemPackages"];
            name = "neovim";
            value = inputs.self.wrapperModules.neovim;
          })
        ];
      };

      # Home-manager module
      homeManager.neovim = {...}: {
        # Import the module from the wrapper
        imports = [
          # The modules are exported in outputs.wrapperModules
          (inputs.wrappers.lib.mkInstallModule {
            # Location to install
            loc = ["home" "packages"];
            name = "neovim";
            value = inputs.self.wrapperModules.neovim;
          })
        ];
      };
    };
  };
}

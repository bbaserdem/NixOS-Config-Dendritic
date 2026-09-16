# Configuring the editor, using the neovim wrapper from this flake
{inputs, ...}: {
  flake.modules = {
    # Nixos and Darwin modules to replace vim command
    # Also sets sudo editor
    generic.nvim = {...}: {
      # Import the generic module
      imports = [
        inputs.self.modules.generic.neovim-wrapper
        inputs.self.modules.generic.neovim-settings
      ];
    };

    homeManager.nvim = {...}: {
      # Import the wrapper module in the home-manager context
      imports = [
        inputs.self.modules.homeManager.neovim-wrapper
        inputs.self.modules.homeManager.neovim-settings
      ];
    };
  };
}

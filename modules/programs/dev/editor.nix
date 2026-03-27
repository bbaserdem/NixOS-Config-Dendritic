# Configuring the editor, using the neovim wrapper from this flake
{inputs, ...}: {
  flake.modules = {
    # Nixos and darwin modules to replace vim command
    # Also sets sudo editor
    generic.vim = {
      lib,
      pkgs,
      config,
      ...
    }: {
      # Import the generic module
      imports = [
        inputs.self.modules.generic.neovim
      ];

      # Configure minimal instance
      config = {
        # Configure this neovim instance
        wrappers.neovim = {...}: {
          # Enable nvim
          enable = true;
          # Use neovim from regular nixpkgs
          package = pkgs.neovim-unwrapped;
          # Replace vim
          binName = "vim";
          settings = {
            dont_link = true;
            # Remove all plugins
            minimal = true;
            # Set colorscheme to differentiate instance
            colorscheme = {
              dark = "minicrimson";
              light = "minicrimson";
            };
          };
        };
      };

      # Set the sudo editor
      environment.variables = {
        SUDO_EDITOR = lib.getExe config.wrappers.neovim.wrapper;
      };
    };

    # Home manager module to install full neovim module
    homeManager.neovim = {
      options,
      config,
      lib,
      ...
    }: let
      # Load stylix colors if they are available
      stylixColors =
        if (builtins.hasAttr "stylix" options.lib)
        then
          (lib.filterAttrs (
              k: v: ((builtins.match "base0[0-9A-F]" k) != null)
            )
            config.lib.stylix.colors.withHashtag)
        else null;
    in {
      # Import the wrapper module in the home-manager context
      imports = [
        inputs.self.modules.homeManager.neovim
      ];

      config = {
        # Configure this neovim instance
        wrappers.neovim = {...}: {
          # Enable nvim
          enable = true;
          # Pass stylix theme through if loaded
          settings.colorscheme.base16 = stylixColors;
          # Enable neovide
          hosts.neovide.nvim-host.enable = true;
        };
      };
    };
  };
}

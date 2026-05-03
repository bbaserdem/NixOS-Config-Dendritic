# Configuring the editor, using the neovim wrapper from this flake
# Important; the name nvim is crucial to distinguish from the neovim wrapper
{inputs, ...}: {
  flake.modules = {
    # Nixos and Darwin modules to replace vim command
    # Also sets sudo editor
    generic.nvim = {
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
          package = lib.mkForce pkgs.neovim-unwrapped;
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

        # Set the vim mode as the sudo editor
        # TODO: Pull to nixos system
        environment.variables = {
          SUDO_EDITOR = lib.getExe config.wrappers.neovim.wrapper;
        };
      };
    };

    homeManager.nvim = {
      options,
      config,
      lib,
      pkgs,
      ...
    }: let
      # Load stylix colors if they are available
      stylixColors =
        if (lib.hasAttrByPath ["stylix"] options.lib)
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
          settings.colorscheme.base16.dark = stylixColors;
          # Enable neovide
          hosts.neovide.nvim-host.enable = true;
        };
      };
    };
  };
}

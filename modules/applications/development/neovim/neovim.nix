# Configuring neovim the editor, using the neovim wrapper from this flake
{inputs, ...}: {
  # Den config
  den = {
    aspects.applications = {
      provides.neovim = {
        # System level module for installing neovim to the system
        os = {...}: {
          imports = with inputs.self.modules.generic; [
            neovim-wrapper
            neovim-settings
          ];
        };
        # Settings to be sent to users
        provides.to-users = {
          host,
          user,
        }: {
          # Collision protection
          name = "applications/neovim(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              neovim-wrapper
              neovim-settings
            ];
          };
          # Explicitly disable stylix; we do our own integration
          stylix = {
            targets = {
              neovim.enable = false;
              nixvim.enable = false;
              nvf.enable = false;
              vim.enable = false;
            };
          };
        };
      };
    };
  };
  flake.modules = {
    # Nixos and Darwin modules to replace vim command
    # Also sets sudo editor
    generic.neovim-settings = {
      lib,
      pkgs,
      config,
      ...
    }: {
      key = "neovim-settings#generic";
      # Import the wrapper module; can't do without it (redundant in den)
      imports = [
        inputs.self.modules.generic.neovim-wrapper
      ];

      # Configure minimal instance for the OS; needs wrapper module loaded
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
            # Set colorscheme to differentiate instance visually
            colorscheme = {
              dark = "minicrimson";
              light = "minicrimson";
            };
          };
        };

        # Set the vim mode as the sudo editor
        environment.variables = {
          SUDO_EDITOR = lib.getExe config.wrappers.neovim.wrapper;
          SOPS_EDITOR = lib.getExe config.wrappers.neovim.wrapper;
        };
      };
    };

    homeManager.neovim-settings = {
      options,
      config,
      lib,
      ...
    }: {
      key = "neovim-settings#homeManager";
      # Import the wrapper module in the home-manager context (redundant in den)
      imports = [
        inputs.self.modules.homeManager.neovim-wrapper
      ];

      config = let
        # Load stylix colors if they are available
        stylixColors =
          if (lib.hasAttrByPath ["lib" "stylix"] options)
          then
            (
              lib.filterAttrs
              (k: v: ((builtins.match "base0[0-9A-F]" k) != null))
              config.lib.stylix.colors.withHashtag
            )
          else null;
      in {
        # Configure this neovim instance
        wrappers.neovim = {...}: {
          # Enable nvim
          enable = true;
          # Pass stylix theme through if loaded to dark theme
          settings.colorscheme.base16.dark = stylixColors;
          # Enable neovide in case it's here
          hosts.neovide.nvim-host.enable = true;
        };
      };
    };
  };
}

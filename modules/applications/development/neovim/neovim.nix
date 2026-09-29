# Configuring neovim
{
  inputs,
  lib,
  den,
  ...
}: {
  # Den
  den = {
    schema.host = {
      includes = [
        den.aspects.development.policies.neovim-dispatch
      ];
      options = {
        development = lib.mkOption {
          type = lib.types.submodule {
            options = {
              neovim = lib.mkOption {
                description = "Neovim settings";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Whether to install neovim to this host.";
                      default = true;
                      type = lib.types.bool;
                    };
                    guiEnable = lib.mkOption {
                      description = "Whether to install neovide as nvim GUI";
                      default = false;
                      type = lib.types.bool;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    # Aspect
    aspects.development = {
      policies.neovim-dispatch = {host, ...}:
        lib.optionals
        host.development.neovim.enable
        (
          [
            (den.lib.policy.include den.aspects.development._.neovim)
          ]
          ++ (
            lib.optional host.development.neovim.guiEnable
            (den.lib.policy.include den.aspects.development._.neovim._.neovide)
          )
        );

      provides.neovim = {
        name = "development/neovim";
        # System level module for installing neovim to the system
        os = {...}: {
          imports = with inputs.self.modules.generic; [
            neovim-settings
          ];
        };
        # Settings to be sent to users
        provides.to-users = {
          host,
          user,
        }: {
          name = "development/neovim(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              neovim-settings
            ];
          };
          # Explicitly disable stylix; we do our own integration for this
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
    # Wrapper modules; it's a generic module for all contexts
    generic.neovim-wrapper = {...}: {
      key = "neovim-wrapper#generic";
      imports = [
        inputs.self.wrappers.neovim.install
      ];
    };
    homeManager.neovim-wrapper = {...}: {
      key = "neovim-wrapper#homeManager";
      imports = [
        inputs.self.wrappers.neovim.install
      ];
    };

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

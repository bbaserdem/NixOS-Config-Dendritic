# Base entry for shell modules
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    # New option for default login shells
    # TODO: Add other shell options too
    schema.host = {
      options = {
        defaultShell = lib.mkOption {
          description = "Default shell setting for users on this host";
          default = "zsh";
          type = lib.types.nullOr (lib.types.enum [
            "zsh"
          ]);
        };
      };
    };

    aspects.shell = {
      includes = [
        # Default shell setting dispatcher
        den.aspects.shell.policies.default-shell
      ];

      # Policy for auto-setting default shells; must be defined!
      policies.default-shell = {host, ...}:
        if (host.defaultShell != null)
        then [
          (
            den.lib.policy.include
            den.aspects.shell._."default-shell-${host.defaultShell}"
          )
        ]
        else [];

      os = {...}: {
        imports = with inputs.self.modules.generic; [
          shell-zsh
        ];
      };

      nixos = {...}: {
        imports = with inputs.self.modules.nixos; [
          shell-bash
          shell-path
          shell-starship
          shell-zsh
        ];
      };

      darwin = {...}: {
        imports = with inputs.self.modules.darwin; [
          shell-path
          shell-zsh
        ];
      };

      homeManager = {...}: {
        # imports = with inputs.self.modules.homeManager; [ ];
      };

      stylix = {...}: {
      };

      # User scope walkout
      provides.to-users = {
        host,
        user,
      }: {
        homeManager = {...}: {
          imports = with inputs.self.modules.homeManager; [
            shell-bash
            shell-starship
            shell-zsh
          ];
        };
        stylix = {...}: {
          targets = {
            bat.enable = true;
          };
        };
      };
    };

    # Shell extras
    aspects.shell-extra = {
      generic = {...}: {
        # imports = with inputs.self.modules.generic; [ ];
      };
      nixos = {...}: {
        # imports = with inputs.self.modules.nixos; [ ];
      };
      darwin = {...}: {
        # imports = with inputs.self.modules.darwin; [ ];
      };
      homeManager = {...}: {
        # imports = with inputs.self.modules.homeManager; [ ];
      };
      stylix = {...}: {
      };

      # User scope walkout
      provides.to-users = {
        host,
        user,
      }: {
        homeManager = {...}: {
          imports = with inputs.self.modules.homeManager; [
            shell-alias
            shell-apps
            shell-direnv
            shell-fzf
            shell-man
            shell-tmux
            shell-vivid
            shell-zoxide
          ];
        };
        stylix = {...}: {
          targets = {
            tmux.enable = true;
            fzf.enable = true;
            vivid = {
              enable = true;
              colors.enable = true;
            };
          };
        };
      };
    };
  };

  # TODO: Nuke this after den migration
  flake.modules = {
    generic.shell = {...}: {
      imports = with inputs.self.modules.generic; [
        shell-zsh
      ];
    };
    nixos.shell = {...}: {
      imports = with inputs.self.modules.nixos; [
        shell-bash
        shell-path
        shell-starship
        shell-zsh
        shell-zsh-default
      ];
    };
    darwin.shell = {...}: {
      imports = with inputs.self.modules.darwin; [
        shell-path
        shell-zsh
      ];
    };
    homeManager.shell = {...}: {
      imports = with inputs.self.modules.homeManager; [
        shell-alias
        shell-apps
        shell-bash
        shell-direnv
        shell-fzf
        shell-man
        shell-starship
        shell-tmux
        shell-vivid
        shell-zsh
        shell-zoxide
      ];
    };
  };
}

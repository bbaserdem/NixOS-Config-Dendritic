# Base entry for shell environment related setup
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # New option for default login shells
    # TODO: Add other shell options too
    schema = {
      host = {
        includes = [
          den.aspects.shell
          den.aspects.shell.policies.default-host-shell
        ];
        options = {
          shell = lib.mkOption {
            description = "Shell setup metadata";
            default = {};
            type = lib.types.submodule {
              options = {
                default = lib.mkOption {
                  description = "Default shell to use for this host.";
                  default = "zsh";
                  type = lib.types.nullOr (lib.types.enum [
                    "zsh"
                  ]);
                };
                extras = lib.mkOption {
                  description = "If set to false, only a minimal feature set will be enabled.";
                  default = true;
                  type = lib.types.bool;
                };
              };
            };
          };
        };
      };
      user = {
        includes = [
          # Don't need explicit; fanout dispatches to-users properly
          den.aspects.shell.policies.default-user-shell
        ];
        options = {
          defaultShell = lib.mkOption {
            description = "Default shell setting for this user";
            default = "zsh";
            type = lib.types.nullOr (lib.types.enum [
              "zsh"
            ]);
          };
        };
      };
    };

    aspects.shell = {
      # Base aspect; dispatch to everyone
      name = "shell";
      os = {...}: {
        imports = [
          inputs.self.modules.generic.shell-apps
        ];
      };
      nixos = {...}: {
        imports = [
          inputs.self.modules.nixos.shell-path
        ];
      };
      darwin = {...}: {
        imports = [
          inputs.self.modules.darwin.shell-path
        ];
      };
      homeManager = {...}: {
        imports = [
          inputs.self.modules.homeManager.shell-apps
        ];
      };
      provides.to-users = {
        host,
        user,
      }: {
        name = "shell(${user.userName}@${host.name})";
        homeManager = {...}: {
          imports = [
            inputs.self.modules.homeManager.shell-alias
          ];
          config = {
            home.shell.enableShellIntegration = true;
          };
        };
      };

      # Dispatch policies
      policies = {
        # Get the default host shell
        default-host-shell = {host, ...}:
          (
            lib.optionals
            (host.shell.default != null)
            [
              (den.lib.policy.include den.aspects.shell._.default-shell._.host-setup)
              (den.lib.policy.include den.aspects.shell._.${host.shell.default})
            ]
          )
          ++ ( # Also a list of all user enabled shells
            host.users
            |> builtins.attrValues
            |> builtins.map (u: u.defaultShell)
            |> builtins.filter (u: u != null)
            |> lib.unique
            |> builtins.map (
              u: (den.lib.policy.include den.aspects.shell._.${u})
            )
          );
        # Get the default user shell
        default-user-shell = {user, ...}:
          lib.optionals
          (user.defaultShell != null)
          [
            (den.lib.policy.include den.aspects.shell._.default-shell._.user-setup)
            (den.lib.policy.include den.aspects.shell._.${user.defaultShell}._.to-users)
          ];
      };
      # Default shell provides
      provides = {
        default-shell = {
          name = "shell/default-shell";
          provides.host-setup = {host}: {
            name = "shell/default-shell(@${host.name})";
            os = {...}: {
              # Enable this shell module
              programs.${host.shell.default}.enable = true;
            };
            darwin = {pkgs, ...}: {
              # Darwin modules don't auto-configure this; add it manually
              environment.shells =
                if host.shell.default == "bash"
                then [pkgs.bashInteractive]
                else [pkgs.${host.shell.default}];
            };
            nixos = {pkgs, ...}: {
              users = {
                # Nixos also has this option
                defaultUserShell =
                  if host.shell.default == "bash"
                  then pkgs.bashInteractive
                  else pkgs.${host.shell.default};
              };
            };
          };
          provides.user-setup = {
            host,
            user,
          }: {
            name = "shell/default-shell(${user.userName}@${host.name})";
            homeManager = {...}: {
              # Enable the shell module
              programs.${user.defaultShell}.enable = true;
            };
            user = {pkgs, ...}: {
              shell =
                if user.defaultShell == "bash"
                then pkgs.bashInteractive
                else pkgs.${user.defaultShell};
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = let
    shellApps = pkgs:
      with pkgs; [
        skim
        tree
      ];
  in {
    # Userspace apps in env
    generic.shell-apps = {pkgs, ...}: {
      key = "shell-apps#generic";
      config = {
        environment.systemPackages = shellApps pkgs;
      };
    };
    # Environment path
    nixos.shell-path = {...}: {
      key = "shell-path#nixos";
      config = {
        environment.localBinInPath = true;
      };
    };
    darwin.shell-path = {...}: {
      key = "shell-path#darwin";
      config = {
        # Add local bin to path manually
        environment.systemPath = ["$HOME/.local/bin"];
      };
    };

    homeManager = {
      shell-alias = {...}: {
        key = "shell-alias#homeManager";
        config = {
          home.shellAliases = {
            ls = "ls --color";
            ll = "ls -l";
            cd-flake = "cd \${NH_FLAKE}";
          };
        };
      };
      shell-apps = {pkgs, ...}: {
        key = "shell-apps#homeManager";
        config = {
          home.packages = shellApps pkgs;
        };
      };
    };
  };
}

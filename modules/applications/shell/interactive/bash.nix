# Bash config
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    schema = {
      host = {
        includes = [
          den.aspects.shell.policies.bash-host-dispatch
        ];
        options = {
          shell = lib.mkOption {
            type = lib.types.submodule {
              options = {
                bash = lib.mkOption {
                  description = "Enable bash on this host";
                  default = true;
                  type = lib.types.bool;
                };
              };
            };
          };
        };
      };
      user.includes = [
        den.aspects.shell.policies.bash-user-dispatch
      ];
    };

    # Aspect
    aspects.shell = {
      # Dispatch policies for explicit enable
      policies = {
        bash-host-dispatch = {host, ...}:
          lib.optional
          host.shell.bash
          (den.lib.policy.include den.aspects.shell._.bash);
        # Get the default user shell
        bash-user-dispatch = {host, ...}:
          lib.optional
          host.shell.bash
          (den.lib.policy.include den.aspects.shell._.bash._.to-users);
      };

      # Aspect
      provides.bash = {
        name = "shell/bash";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.shell-bash
          ];
        };
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/bash(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.shell-bash
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Setup system bash
    nixos.shell-bash = {...}: {
      key = "shell-bash#nixos";
      config = {
        # Bash options
        programs.bash = {
          # Undistract me stuff
          undistractMe = {
            enable = true;
            timeout = 20;
            playSound = false;
          };
          # Bash settings
          vteIntegration = true;
          interactiveShellInit = ''
            # Fix colors in bash
            case $${TERM} in
              xterm-color|*-256color|xterm-kitty) color_prompt=yes;;
            esac
          '';
        };
      };
    };

    # Setup bash per user
    homeManager.shell-bash = {...}: {
      key = "shell-bash#homeManager";
      config = {
        # Integrations
        home.shell.enableBashIntegration = true;
        services = {
          gpg-agent.enableBashIntegration = true;
        };
        programs.bash = {
          enable = true;
          enableCompletion = true;
          enableVteIntegration = true;
          historyControl = ["ignoredups"];
        };
      };
    };
  };
}

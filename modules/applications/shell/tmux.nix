# Tmux
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Schema registry
    schema = {
      host.includes = [den.aspects.shell.policies.tmux-host-dispatch];
      user.includes = [den.aspects.shell.policies.tmux-user-dispatch];
    };

    aspects.shell = {
      policies = {
        tmux-host-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.tmux);
        tmux-user-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.tmux._.to-users);
      };

      provides.tmux = {
        name = "shell/tmux";
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/tmux(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.shell-tmux
            ];
          };
          stylix = {
            targets.tmux = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Tmux settings
  flake.modules.homeManager.shell-tmux = {...}: {
    key = "shell-tmux#homeManager";
    config = {
      # Settings
      programs = {
        tmux = {
          enable = true;
          baseIndex = 0;
          clock24 = true;
          mouse = true;
          prefix = "C-a";
          sensibleOnTop = true;
          tmuxinator.enable = true;
          tmuxp.enable = true;
          extraConfig = ''
            # Split panes
            bind | split-window -h
            bind - split-window -v
            unbind '"'
            unbind %

            # Change panes with Alt-arrow
            bind -n M-Left  select-pane -L
            bind -n M-Right select-pane -R
            bind -n M-Up    select-pane -U
            bind -n M-Down  select-pane -D

            # Turn off bell
            set -g visual-activity off
            set -g visual-bell off
            set -g visual-silence off
            set -g bell-action none
            setw -g monitor-activity off
          '';
        };
        fzf.tmux = {
          enableShellIntegration = true;
        };
      };
    };
  };
}

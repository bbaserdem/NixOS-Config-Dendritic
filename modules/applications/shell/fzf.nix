# Fuzzy finder
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Schema registry
    schema = {
      host.includes = [den.aspects.shell.policies.fzf-host-dispatch];
      user.includes = [den.aspects.shell.policies.fzf-user-dispatch];
    };

    aspects.shell = {
      policies = {
        fzf-host-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.fzf);
        fzf-user-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.fzf._.to-users);
      };

      provides.fzf = {
        name = "shell/fzf";
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/fzf(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.shell-fzf
            ];
          };
          stylix = {
            targets.fzf = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.shell-fzf = {...}: {
    key = "shell-fzf#homeManager";
    config = {
      programs.fzf = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}

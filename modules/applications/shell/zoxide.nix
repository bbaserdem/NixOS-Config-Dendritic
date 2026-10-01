# Smart directory navigation
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Schema registry
    schema = {
      host.includes = [den.aspects.shell.policies.zoxide-host-dispatch];
      user.includes = [den.aspects.shell.policies.zoxide-user-dispatch];
    };

    aspects.shell = {
      policies = {
        zoxide-host-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.zoxide);
        zoxide-user-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.zoxide._.to-users);
      };

      provides.zoxide = {
        name = "shell/zoxide";
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/zoxide(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.shell-zoxide
            ];
          };
        };
      };
    };
  };

  flake.modules.homeManager.shell-zoxide = {...}: {
    key = "shell-zoxide#homeManager";
    config = {
      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };
    };
  };
}

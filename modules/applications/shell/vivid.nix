# Shell colorizer
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Schema registry
    schema = {
      host.includes = [den.aspects.shell.policies.vivid-host-dispatch];
      user.includes = [den.aspects.shell.policies.vivid-user-dispatch];
    };

    aspects.shell = {
      policies = {
        vivid-host-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.vivid);
        vivid-user-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.vivid._.to-users);
      };

      provides.vivid = {
        name = "shell/vivid";
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/vivid(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.shell-vivid
            ];
          };
          stylix = {
            targets.vivid = {
              enable = true;
              colors.enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.shell-vivid = {...}: {
    key = "shell-vivid#homeManager";
    config = {
      programs.vivid = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };
    };
  };
}

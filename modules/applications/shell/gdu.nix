# GDU; go disk usage
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Schema registry
    schema = {
      host.includes = [den.aspects.shell.policies.gdu-host-dispatch];
      user.includes = [den.aspects.shell.policies.gdu-user-dispatch];
    };

    aspects.shell = {
      policies = {
        gdu-host-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.gdu);
        gdu-user-dispatch = {host, ...}:
          lib.optional
          host.shell.extras
          (den.lib.policy.include den.aspects.shell._.gdu._.to-users);
      };

      provides.gdu = {
        name = "shell/gdu";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.shell-gdu
          ];
        };
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/gdu(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.shell-gdu
            ];
          };
        };
      };
    };
  };

  flake.modules = {
    nixos.shell-gdu = {pkgs, ...}: {
      key = "shell-gdu#nixos";
      config = {
        environment.systemPackages = with pkgs; [
          gdu
        ];
      };
    };
    homeManager.shell-gdu = {
      pkgs,
      lib,
      ...
    }: {
      key = "shell-gdu#homeManager";
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = with pkgs; [
          gdu
        ];
      };
    };
  };
}

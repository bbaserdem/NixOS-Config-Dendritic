# Aria2; download manager
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Schema; register policies
    schema = {
      host = {
        includes = [
          den.aspects.tools.policies.aria2-host-dispatch
        ];
        options = {
          tools = lib.mkOption {
            type = lib.types.submodule {
              options = {
                aria2 = lib.mkOption {
                  description = "Enable aria2";
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
          den.aspects.tools.policies.aria2-user-dispatch
        ];
      };
    };
    aspects.tools = {
      # Policy
      policies = {
        aria2-host-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.aria2)
          [
            (den.lib.policy.include den.aspects.tools._.aria2)
          ];
        aria2-user-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.aria2)
          [
            (den.lib.policy.include den.aspects.tools._.aria2._.to-users)
          ];
      };
      # Aspect
      provides.aria2 = {
        name = "tools/aria2";
        provides.to-users = {
          host,
          user,
        }: {
          # Clash check
          name = "tools/aria2(${user.userName}@${host.name})";
          # Module dispatch
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.aria2
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.aria2 = {pkgs, ...}: {
    key = "aria2#homeManager";
    config = {
      programs = {
        # The main daemon
        aria2 = {
          enable = true;
          systemd.enable = pkgs.stdenv.hostPlatform.isLinux;
          settings = {
          };
        };
        # Python cli interactive tool
        aria2p = {
          enable = pkgs.stdenv.hostPlatform.isLinux;
          settings = {
          };
        };
      };
    };
  };
}

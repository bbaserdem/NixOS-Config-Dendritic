# Btop; system monitor settings
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
          den.aspects.tools.policies.btop-host-dispatch
        ];
        options = {
          tools = lib.mkOption {
            type = lib.types.submodule {
              options = {
                btop = lib.mkOption {
                  description = "Enable btop";
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
          den.aspects.tools.policies.btop-user-dispatch
        ];
      };
    };
    aspects.tools = {
      # Policy
      policies = {
        btop-host-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.btop)
          [
            (den.lib.policy.include den.aspects.tools._.btop)
          ];
        btop-user-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.btop)
          [
            (den.lib.policy.include den.aspects.tools._.btop._.to-users)
          ];
      };
      # Aspect
      provides.btop = {
        name = "tools/btop";
        provides.to-users = {
          host,
          user,
        }: {
          # Clash check
          name = "tools/btop(${user.userName}@${host.name})";
          # Module dispatch
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.btop-settings
            ];
          };
          # Styling
          stylix = {
            targets.btop = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.btop-settings = {...}: {
    key = "btop-settings#homeManager";
    config = {
      programs.btop = {
        enable = true;
        settings = {
          proc_sorting = "cpu lazy";
        };
      };
    };
  };
}

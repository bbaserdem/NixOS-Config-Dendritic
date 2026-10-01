# Udisks management in nixos
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
          den.aspects.tools.policies.udisks-host-dispatch
        ];
        options = {
          tools = lib.mkOption {
            type = lib.types.submodule {
              options = {
                udisks = lib.mkOption {
                  description = "Enable udisks (udiskie)";
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
          den.aspects.tools.policies.udisks-user-dispatch
        ];
      };
    };

    aspects.tools = {
      # Ship policies; we do need user level dispatch here as well for hm
      policies = {
        udisks-host-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.udisks)
          [
            (den.lib.policy.include den.aspects.tools._.udisks)
          ];
        udisks-user-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.udisks)
          [
            (den.lib.policy.include den.aspects.tools._.udisks._.to-users)
          ];
      };

      provides.udisks = {
        name = "tools/udisks";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.udisks-settings
          ];
        };
        provides.to-users = {
          user,
          host,
        }: {
          name = "tools/udisks(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.udisks-settings
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    nixos.udisks-settings = {...}: {
      key = "udisks-settings#nixos";
      config = {
        services.udisks2 = {
          enable = true;
        };
      };
    };
    homeManager.udisks-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "udisks-settings#homeManager";
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        services.udiskie = {
          enable = true;
          tray = "always";
          notify = true;
          automount = false;
        };
      };
    };
  };
}

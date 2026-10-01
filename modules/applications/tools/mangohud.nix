# Mangohud; performance measurement
{
  inputs,
  den,
  lib,
  ...
}: {
  # Aspect for configuration
  den = {
    # Schema; register policies
    schema = {
      host = {
        includes = [
          den.aspects.tools.policies.mangohud-host-dispatch
        ];
        options = {
          tools = lib.mkOption {
            type = lib.types.submodule {
              options = {
                mangohud = lib.mkOption {
                  description = "Enable mangohud";
                  default = false;
                  type = lib.types.bool;
                };
              };
            };
          };
        };
      };
      user = {
        includes = [
          den.aspects.tools.policies.mangohud-user-dispatch
        ];
      };
    };

    aspects.tools = {
      # Policy
      policies = {
        mangohud-host-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.mangohud)
          [
            (den.lib.policy.include den.aspects.tools._.mangohud)
          ];
        mangohud-user-dispatch = {host, ...}:
          lib.optionals
          (host.tools.enable || host.tools.mangohud)
          [
            (den.lib.policy.include den.aspects.tools._.mangohud._.to-users)
          ];
      };
      # Aspect
      provides.mangohud = {
        name = "tools/mangohud";
        provides.to-users = {
          host,
          user,
        }: {
          name = "tools/mangohud(${user.userName}@${host.name})";
          # Home manager module loading
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.mangohud-settings
            ];
          };
          # Stylix theming
          stylix = {
            targets.mangohud = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Settings module
  flake.modules.homeManager.mangohud-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "mangohud-settings#homeManager";
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      programs.mangohud = {
        enable = true;
        enableSessionWide = false;
      };
    };
  };
}

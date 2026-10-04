# General systems boilerplate for den
{
  den,
  lib,
  ...
}: {
  den = {
    schema = {
      host = {
        includes = [
          # Always include the base system in every host scope
          den.aspects.system
          # State version setting policy
          den.aspects.system.policies.host-state-version-dispatch
        ];
        imports = [
          ({config, ...}: {
            options = {
              # System state version
              stateVersion = lib.mkOption {
                description = "Host specific stateVersion string";
                type = lib.types.nullOr (lib.types.oneOf [
                  lib.types.str
                  lib.types.int
                ]);
                default = null;
              };
              # Primary user setting
              primaryUser = lib.mkOption {
                description = "The primary user that will be using this host.";
                type = lib.types.nullOr lib.types.str;
                default = null;
                apply = n:
                  if n == null
                  then null
                  else if (builtins.elem n (builtins.attrNames config.users))
                  then n
                  else throw "primaryUser (${n}) is not in this hosts' users list.";
              };
            };
          })
        ];
      };
      user = {
        includes = [
          # State version setting policy
          den.aspects.system.policies.user-state-version-dispatch
        ];
        options = {
          # System state version
          stateVersion = lib.mkOption {
            description = "User's specific stateVersion string";
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      };
    };

    # System aspect; generic module dispatching to appropriate outputs
    aspects.system = {
      name = "system";
      includes = [
        den.aspects.system._.platform-dispatch
      ];
      policies = {
        host-state-version-dispatch = {host, ...}:
          lib.optional
          (host.stateVersion != null)
          (den.lib.policy.include den.aspects.system._.host-state-version);
        user-state-version-dispatch = {user, ...}:
          lib.optional
          (user.stateVersion != null)
          (den.lib.policy.include den.aspects.system._.user-state-version);
      };

      provides = {
        # Needs to happen with an aspect; since policies don't fire recursively
        # TODO: This is a hack; policy rolled in aspect. If den fixes this, great.
        platform-dispatch = {host}: {
          name = "system/platform-dispatch(@${host.name})";
          includes =
            (
              # Set up NixOS base config
              lib.optional
              (host.class == "nixos")
              den.aspects.system._.nixos
            )
            ++ (
              # Set up MacOS base config
              lib.optional
              (host.class == "darwin")
              den.aspects.system._.macos
            );
        };

        # State version settings
        host-state-version = {host}: {
          name = "system/state-version(@${host.name})";
          # For nixos and darwin
          os = {lib, ...}: {
            config = lib.mkIf (builtins.elem host.class ["nixos" "darwin"]) {
              system.stateVersion = lib.mkOverride 105 host.stateVersion;
            };
          };
          # For home-manager standalone (can't reuse os level setting from other)
          homeManager = {lib, ...}: {
            config = lib.mkIf (builtins.elem host.class ["homeManager"]) {
              home.stateVersion = lib.mkOverride 105 host.stateVersion;
            };
          };
        };
        # User state version for hm; overrides host-level default
        user-state-version = {
          host,
          user,
        }: {
          name = "system/state-version(${user.userName}@${host.name})";
          homeManager = {lib, ...}: {
            config = {
              home.stateVersion = lib.mkOverride 101 user.stateVersion;
            };
          };
        };
      };
    };
  };
}

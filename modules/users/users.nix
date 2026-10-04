# User configuration in den
{
  den,
  lib,
  flib,
  ...
}: {
  den = {
    # User classes; admin access
    classes = {
      admin.description = "User class for users with sudo access";
    };

    # Schema changes
    schema = {
      # We are removing home entities
      flake-system.excludes = [
        den.policies.system-to-hm-outputs
      ];

      # Config option; home directory from record
      user = {
        imports = [
          ({config, ...}: {
            options = {
              # Store home directory location in entity record
              homeDirectory = lib.mkOption {
                type = flib.types.absolutePath;
                description = "User's home directory path";
                default =
                  if (lib.hasSuffix "darwin" config.host.system)
                  then "/Users/${config.userName}"
                  else "/home/${config.userName}";
              };
              # Whether to have this user as trusted nix user
              nixTrusted = lib.mkOption {
                type = lib.types.bool;
                description = "Flag to include user in nix group";
                default = config.userName == config.host.primaryUser;
              };
            };
          })
        ];
        includes = [
          # By default, no need for policy on this
          den.aspects.system._.define-user
          # Administrator privileges to user
          den.aspects.system.policies.user-admin-dispatch
          den.aspects.system.policies.user-nix-trust-dispatch
          # User aspect base
          den.aspects.user
        ];
      };
    };

    aspects = {
      # Base aspect to include in all users
      user = {
        name = "user";
      };

      # System setup related dispatches
      system = {
        policies = {
          user-admin-dispatch = {
            user,
            host,
            ...
          }:
            lib.optional
            (
              (builtins.elem "admin" user.classes)
              || (host.primaryUser == user.userName)
            )
            (den.lib.policy.include den.aspects.system._.admin-role);
          user-nix-trust-dispatch = {
            user,
            host,
            ...
          }:
            lib.optional
            (user.nixTrusted || (host.primaryUser == user.userName))
            (den.lib.policy.include den.aspects.system._.nix-role);
        };
        # We provide our own user definition battery;
        # We want den metadata, not present in define-user battery
        provides = {
          define-user = {
            host,
            user,
          }: {
            # Collision prevention
            name = "system/define-user(${user.userName}@${host.hostName})";
            # We use the built-in os-user battery's class for this
            user = {...}: {
              name = user.userName;
              home = user.homeDirectory;
            };
            # Platform specific settings
            nixos = {lib, ...}: {
              users.users.${user.userName}.isNormalUser = lib.mkDefault true;
            };
            homeManager = {...}: {
              home.username = user.userName;
              home.homeDirectory = user.homeDirectory;
            };
          };
          # Aspect that sets user as an admin in nixos
          admin-role = {
            host,
            user,
          }: {
            name = "system/admin-role(${user.userName}@${host.hostName})";
            user = flib.den.addUserToGroups ["wheel"];
          };
          # Aspect that sets user as trusted for nix
          nix-role = {
            host,
            user,
          }: {
            name = "system/nix-role(${user.userName}@${host.hostName})";
            os = {...}: {
              config = {
                nix.settings.trusted-users = [user.userName];
              };
            };
            user = flib.den.addUserToGroups ["nix"];
          };
        };
      };
    };
  };
}

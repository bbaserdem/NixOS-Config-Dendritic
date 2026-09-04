# User configuration in den
{
  den,
  lib,
  flib,
  ...
}: {
  den = {
    schema = {
      flake-system = {
        excludes = [
          # We are removing home entities, don't need this
          den.policies.system-to-hm-outputs
        ];
      };

      # Config option for home directory
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
              # Internal enum field, for calculating per-user differences
              enum = lib.mkOption {
                type = lib.types.ints.unsigned;
                readOnly = true;
                description = "A metadata tag number for this user on this host.";
                default =
                  config.host.users
                  |> builtins.attrNames
                  |> lib.lists.findFirstIndex
                  (userName: userName == config.name)
                  (throw "Could not enumerate user: `${config.name}`");
              };
            };
          })
        ];
        includes = [
          # By default, no need for policy on this
          den.aspects.system._.define-user
        ];
      };
    };

    aspects.system = {
      # We provide our own user definition battery;
      # We want den metadata, not present in define-user battery
      provides.define-user = {
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
    };
  };
}

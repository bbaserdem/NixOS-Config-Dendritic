# User generation factory function
{inputs, ...}: {
  factory.user = {
    username,
    homeDir ? "/home/${username}",
    isHomeManager ? true,
    isNormalUser ? true,
    isAdmin ? false,
    isNix ? false,
    ...
  }: let
    hostNameLoadingModule = {osConfig, ...}: {
      networking.hostName = osConfig.networking.hostName;
    };
  in {
    # Generic nixos config for this user;
    # Globally dispatch user info, but don't enable them yet.
    nixos.default = {lib, ...}: {
      config = {
        # Register this user in the system definition
        users.users."${username}" = {
          enable = lib.mkOverride 950 false;
        };
      };
    };

    # Nixos module for enabling this user
    nixos."${username}" = {
      lib,
      options,
      ...
    }: {
      config = lib.mkMerge [
        {
          # Manage user groups and settings outside home-manager
          users.users."${username}" = {
            enable = lib.mkOverride 900 true;
            isNormalUser = isNormalUser;
            home = homeDir;
            extraGroups = lib.optionals isAdmin [
              "wheel"
            ];
          };
        }
        (
          # Add to trusted nix users
          lib.mkIf isNix {
            nix.settings.trusted-users = lib.optionals isNix [
              username
            ];
          }
        )
        (
          # Enable home-manager config if option exists, and enabled
          lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) (
            lib.mkIf isHomeManager {
              # Ensure self is loaded
              home-manager.users."${username}".imports = [
                inputs.self.modules.homeManager."${username}"
                hostNameLoadingModule
              ];
            }
          )
        )
      ];
    };

    # Nix-darwin config for the given user, uses home-manager as darwin module
    darwin."${username}" = {
      lib,
      options,
      ...
    }: {
      config = lib.mkMerge [
        {
          users = {
            # Configure user
            users."${username}" = {
              # In darwin, home names are cannonical
              home = "/Users/${username}";
              isHidden = false;
            };
          };
        }
        (
          # Enable home-manager config if option exists, and enabled
          lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) (
            lib.mkIf isHomeManager {
              home-manager.users."${username}".imports = [
                inputs.self.modules.homeManager."${username}"
                hostNameLoadingModule
              ];
            }
          )
        )
      ];
    };

    # Home-manager module initialization for this user
    homeManager."${username}" = {
      config = {
        home.username = "${username}";
      };
    };
  };
}

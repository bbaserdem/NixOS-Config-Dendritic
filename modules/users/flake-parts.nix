# Home-Manager flake-parts boilerplate
{inputs, ...}: {
  # Import the flake-parts modules for home-manager
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  config = {
    flake = {
      modules = {
        # Generic home-manager settings module, for using hm as a system module
        generic.homeManagerOS = {...}: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            overwriteBackup = true;
          };
        };
        # Import home-manager OS module to default OS contexts
        nixos.default = {...}: {
          imports = [
            inputs.home-manager.nixosModules.home-manager
            inputs.self.modules.generic.homeManagerOS
          ];
        };
        darwin.default = {...}: {
          imports = [
            inputs.home-manager.darwinModules.home-manager
            inputs.self.modules.generic.homeManagerOS
          ];
        };
        # Default settings for all home-manager invocations
        # Loaded into context by factory function
        homeManager.default = {lib, ...}: {
          options = {
            # Create a hostName attribute
            # Either inherited from host (nixos, darwin)
            # Or set by standalone hm factory
            # Allows hostname to be queried from hm context without osConfig magic
            networking.hostName = lib.mkOption {
              type = lib.types.str;
              description = ''
                Variable used by modules to identify the machine running the HM config.
                Should be set by flake-module factory functions.
              '';
            };
          };
          config = {
            home.stateVersion = "25.11";
          };
        };
      };

      # User module factory function;
      # Initializes the following;
      # - modules.homeManager: Module to configure user-level hm settings
      # - modules.nixos:       Module to configure user-level os settings
      #                         also initializes the user as hm-module in nixos
      # - modules.darwin:      Module to configure user-level os settings
      #                         also initializes the user as hm-module in darwin
      # Takes is attrset with at least username, and optional flags for user roles
      factory.user = {
        username,
        isNormalUser ? true,
        isAdmin ? false,
        isNix ? false,
        ...
      }: let
        hostNameLoadingModule = {osConfig, ...}: {
          networking.hostName = osConfig.networking.hostName;
        };
      in {
        # Nixos config for this user, this uses home-manager as nixos module
        nixos."${username}" = {lib, ...}: {
          config = {
            # Manage user groups and settings outside home-manager
            users.users."${username}" = {
              isNormalUser = isNormalUser;
              home = "/home/${username}";
              extraGroups = lib.optionals isAdmin [
                "wheel"
                "networkmanager"
              ];
            };
            # Ensure self is loaded
            home-manager.users."${username}".imports = [
              inputs.self.modules.homeManager."${username}"
              hostNameLoadingModule
            ];
            # Add to trusted nix users
            nix.settings.trusted-users = lib.optionals isNix [
              username
            ];
          };
        };

        # Nix-darwin config for the given user, uses home-manager as darwin module
        darwin."${username}" = {...}: {
          config = {
            users = {
              # Configure user
              users."${username}" = {
                home = "/Users/${username}";
                isHidden = false;
              };
            };

            home-manager.users."${username}".imports = [
              inputs.self.modules.homeManager."${username}"
              hostNameLoadingModule
            ];
          };
        };

        # Home-manager module initialization for the user
        homeManager."${username}" = {
          imports = [
            inputs.self.modules.homeManager.default
          ];
          config = {
            home.username = "${username}";
          };
        };
      };
    };
  };
}

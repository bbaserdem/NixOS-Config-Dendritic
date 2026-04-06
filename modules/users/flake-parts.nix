# Home-Manager flake-parts boilerplate
{inputs, ...}: {
  # Import the flake-parts modules for home-manager
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  config = {
    flake = {
      modules = {
        # Default settings for all home-manager invocations
        homeManager.default = {...}: {
          home.stateVersion = "25.11";
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
      }: {
        # Nixos config for this user, this uses home-manager as nixos module
        nixos."${username}" = {
          lib,
          pkgs,
          ...
        }: {
          # Import home-manager module for nixos
          imports = [
            inputs.home-manager.nixosModules.home-manager
          ];
          config = {
            users.users."${username}" = {
              isNormalUser = isNormalUser;
              home = "/home/${username}";
              extraGroups = lib.optionals isAdmin [
                "wheel"
                "networkmanager"
              ];
              shell = pkgs.zsh;
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPkgs = true;
              users."${username}" = {
                imports = [
                  inputs.self.modules.homeManager."${username}"
                ];
              };
            };

            nix.settings.trusted-users = lib.optionals isNix [
              username
            ];
          };
        };

        # Nix-darwin config for the given user, uses home-manager as darwin module
        darwin."${username}" = {
          lib,
          pkgs,
          ...
        }: {
          # Import home-manager module for darwin
          imports = [
            inputs.home-manager.darwinModules.home-manager
          ];
          config = {
            users = {
              # Add us to managed users
              knownUsers = [
                "${username}"
              ];
              # Configure user
              users."${username}" = {
                home = "/Users/${username}";
                isHidden = false;
              };
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${username}" = {
                imports = [
                  inputs.self.modules.homeManager."${username}"
                ];
              };
            };

            system.primaryUser = lib.mkIf isAdmin "${username}";
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

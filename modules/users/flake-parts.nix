# Home-Manager flake-parts boilerplate
{inputs, ...}: {
  # Import the flake-parts modules for home-manager
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  config = {
    flake = {
      # Module to add options to homeManager modules
      modules = {
        generic.userConstants = {lib, ...}: {
          options = {
            username = lib.mkOption {
              type = lib.types.string;
              description = "The username for this system";
              default = "";
            };
          };
        };
      };

      # Standalone home-manager config builder
      # Takes an argument modules to load modules, mostly from this flake
      # While function is defined here, this would be used in host configurations
      lib = {
        mkHome = {
          system,
          user,
          host,
          modules ? [],
          ...
        }: {
          "${user}@${host}" = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs.legacyPackages.${system};
            modules =
              [
                inputs.self.modules.homeManager.${user}
                # Additional modules to load on top of the user one
                inputs.self.modules.generic.nixpkgs
              ]
              ++ modules;
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
            # Configure user
            users.users."${username}" = {
              home = "/Users/${username}";
              shell = pkgs.zsh;
              isHidden = false;
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
            inputs.self.modules.generic.userConstants
            {userConstants.username = username;}
          ];
          config = {
            home.username = "${username}";
          };
        };
      };
    };
  };
}

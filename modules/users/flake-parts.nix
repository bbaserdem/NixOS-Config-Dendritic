# Home-Manager flake-parts setup
{inputs, ...}: {
  # Import the flake-parts modules for home-manager
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  config = {
    flake = {
      # Module to define user constants
      modules = {
        generic.userConstants = {lib, ...}: {
          options = {
            username = lib.mkOption {
              type = lib.types.string;
              description = "The username for this system";
              default = "";
            };
            arch = lib.mkOption {
              type = lib.types.nullOr lib.types.string;
              description = "The system architecture of this user";
              default = null;
            };
          };
        };
      };

      # Standalone home-manager config builder
      # Will not be used in this flake, but is possible
      lib = {
        mkHomeManager = {
          system,
          user,
          ...
        }: {
          ${user} = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs.legacyPackages.${system};
            modules = [
              inputs.self.modules.homeManager.${user}
              # Additional modules to load on top of the user one
              {
                userConstants = {
                  arch = system;
                };
              }
              inputs.self.modules.generic.nixpkgs
            ];
          };
        };
      };

      # User module factory function;
      # Initializes home-manager module for the user
      # And creates nixos and darwin modules to add user to context
      # Takes is attrset with at least username, and optional flags for user roles
      factory.user = {
        username,
        isNormalUser ? true,
        isAdmin ? false,
        isNix ? false,
        ...
      }: {
        # Nixos config for thin user, this uses home-manager as nixos module
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
              ];
              shell = pkgs.zsh;
            };
            programs.zsh.enable = true;

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
            programs.zsh.enable = true;
          };
        };

        # Home-manager module initialization for the user
        homeManager."${username}" = {
          imports = [
            inputs.self.modules.generic.userConstants
            {
              userConstants = {
                username = username;
              };
            }
          ];
          config = {
            home.username = "${username}";
          };
        };
      };
    };
  };
}

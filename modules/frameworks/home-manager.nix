# Home-Manager system context modules
{
  inputs,
  config,
  den,
  ...
}: let
  version = config.localConfig.nixVersion;
in {
  # Load the home-manager flake-parts module
  imports = [
    (inputs.home-manager.flakeModules.home-manager or {})
  ];

  config = {
    # Home-manoger flake source
    flake-file.inputs = {
      home-manager = {
        url = "github:nix-community/home-manager/release-${version}";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      home-manager-unstable = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    # Configuring default hm settings in den
    # In den, there are shipped home-manager battery
    # - when host aspect uses it; imports nixos/darwin modules into their scope
    # - dispatches user's entire resovled graph's homeManager class to home-manager.users.<user>
    # - homeManager class registered;
    # host configuration can go in den.schema.hm-host.includes (undocumented)
    den = {
      # Home manager settings configuration aspect
      aspects.home-manager = {
        #  Default stateversion for hm eval
        homeManager = {lib, ...}: {
          home.stateVersion = lib.mkDefault "${version}";
        };
        # We don't globally want to enable os settings; so we are going to
        # hook this as a sub-aspect to schema.hm-host.includes
        provides.osSettings.os = {
          lib,
          options,
          ...
        }: {
          config = lib.optionalAttrs (options ? home-manager) {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              overwriteBackup = true;
            };
          };
        };
      };

      # Dispatch global hm-settings in all relevant scopes;
      # global to homeManager, osSettings to hm-host scope
      default.includes = [den.aspects.home-manager];
      schema.hm-host.includes = [den.aspects.home-manager.provides.settings];
    };

    # System wide home-manager modules;
    # Kept in place until den migration
    flake = {
      modules = let
        # Generic home-manager settings module, for using hm as a system module
        homeManagerOSConfig = {...}: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            overwriteBackup = true;
          };
        };
      in {
        # Dispatch option to register users into enabled hosts list
        generic.homeManager = {lib, ...}: {
          options = {
            local.hm.users = lib.mkOption {
              type = lib.types.attrsOf lib.types.bool;
              default = {};
              description = "Set of home manager enabled users.";
            };
          };
        };
        # Import home-manager OS module to default OS contexts
        nixos.homeManager = {...}: {
          imports = [
            inputs.home-manager.nixosModules.home-manager
            inputs.self.modules.generic.homeManager
            homeManagerOSConfig
          ];
          config = {
            home-manager.sharedModules = [
              inputs.self.modules.homeManager.default
            ];
          };
        };
        darwin.homeManager = {...}: {
          imports = [
            inputs.home-manager.darwinModules.home-manager
            inputs.self.modules.generic.homeManager
            homeManagerOSConfig
          ];
          config = {
            home-manager.sharedModules = [
              inputs.self.modules.homeManager.default
            ];
          };
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
                Should be set by flake-module factory functions
              '';
            };
          };
          config = {
            home.stateVersion = "26.05";
          };
        };
      };
    };
  };
}

# Home-Manager system context modules
{inputs, ...}: {
  # Load the home-manager flake-parts module
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  # System wide home-manager modules
  flake.modules = let
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
        home.stateVersion = "25.11";
      };
    };
  };
}

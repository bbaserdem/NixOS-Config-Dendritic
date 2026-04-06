# Syncthing; file synching solution
{inputs, ...}: {
  flake.modules = {
    # Syncthing setup

    # Generic module, common for NixOS & Home-manager
    # Contains folder/device list
    generic.syncthing = {...}: {
      services.syncthing = {
        enable = true;
        # Runtime behavior
        settings.options = {
          urAccepted = 3;
          relaysEnabled = true;
          localAnnounceEnabled = true;
        };
      };
    };

    # In linux context, we want syncthingtray
    homeManager.syncthing = {
      pkgs,
      lib,
      ...
    } @ args: {
      config = lib.mkMerge [
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            services.syncthing.tray = {
              enable = true;
              package = pkgs.syncthingtray;
            };
          }
        )
        (
          lib.mkIf ((pkgs.stdenv.hostPlatform.isLinux) && (builtins.hasAttr "osConfig" args)) {
            # Somehow link the restApi to be used from osConfig keys
            # Maybe generate the ini file
            #services.syncthing.tray.settings.guiAddressFile = osConfig.sops.secrets."syncthing/restapi".path;
          }
        )
      ];
    };

    # NixOS module
    nixos.syncthing = {config, ...}: let
      nixosKeyOwnership = {
        owner = "syncthing";
        group = "syncthing";
        mode = "0440";
      };
    in {
      # Import module
      imports = [
        inputs.self.modules.generic.syncthing
      ];

      # Provision key Ownership
      sops.secrets = {
        "syncthing/cert" = nixosKeyOwnership;
        "syncthing/key" = nixosKeyOwnership;
        # "syncthing/restapi" = nixosKeyOwnership;
      };

      services.syncthing = {
        # Setup services
        cert = config.sops.secrets."syncthing/cert".path;
        key = config.sops.secrets."syncthing/key".path;
        # https://github.com/NixOS/nixpkgs/pull/401900#event-23372654453
        # apiKeyFile = config.sops.secrets."syncthing/restapi".path;

        # Also enable relays and ports
        openDefaultPorts = true;
        relay.enable = true;

        # The dataDir option is the home directory of the syncthing users
        dataDir = "/home/syncthing";
      };

      # Include the homeManager module to all managed users
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.syncthing
      ];
    };

    # Darwin module
    darwin.syncthing = {...}: let
      darwinKeyOwnership = {
        group = "staff";
        mode = "0440";
      };
    in {
      # Provision key Ownership
      sops.secrets = {
        "syncthing/cert" = darwinKeyOwnership;
        "syncthing/key" = darwinKeyOwnership;
        # "syncthing/restapi" = darwinKeyOwnership;
      };

      # We dispatch as a shared home-manager module, and set keys
      home-manager.sharedModules = [
        ({osConfig, ...}: {
          # Import the common module
          imports = [
            inputs.self.modules.generic.syncthing
            inputs.self.modules.homeManager.syncthing
          ];

          services.syncthing = {
            cert = osConfig.sops.secrets."syncthing/cert".path;
            key = osConfig.sops.secrets."syncthing/key".path;
            # apiKeyFile = osConfig.sops.secrets."syncthing/restapi".path;
          };
        })
      ];
    };
  };
}

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

    homeManager = {
      # Generic home-manager syncthing module
      syncthing = {
        pkgs,
        lib,
        ...
      } @ args: {
        config = lib.mkMerge [
          # In linux context, we want syncthingtray
          (
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              services.syncthing.tray = {
                enable = true;
                package = pkgs.syncthingtray;
              };
            }
          )
          (
            lib.mkIf (
              (pkgs.stdenv.hostPlatform.isLinux)
              && (lib.hasAttrByPath ["osConfig" "sops" "secrets" "syncthing/restapi"] args)
            ) {
              # Somehow link the restApi to be used from osConfig keys
              # Maybe generate the ini file, the tray settings not an option atm
              # services.syncthing.tray.settings.guiAddressFile = args.osConfig.sops.secrets."syncthing/restapi".path;
            }
          )
        ];
      };
      # Dispatch module to grab keys from host configuration
      syncthingKeyDispatch = {lib, ...} @ args: {
        config = lib.mkIf (lib.hasAttrByPath ["osConfig" "sops" "secrets"] args) {
          services.syncthing = {
            cert = args.osConfig.sops.secrets."syncthing/cert".path;
            key = args.osConfig.sops.secrets."syncthing/key".path;
            # apiKey = args.osConfig.sops.secrets."syncthing/restapi".path;
          };
        };
      };
    };

    # NixOS module
    nixos.syncthing = {
      config,
      options,
      lib,
      ...
    }: {
      # Import module
      imports = [
        inputs.self.modules.generic.syncthing
      ];

      config = lib.mkMerge [
        {
          services.syncthing = {
            # Enable relays and ports
            openDefaultPorts = true;
            relay.enable = true;

            # The dataDir option is the home directory of the syncthing users
            dataDir = "/home/syncthing";

            # Dispatch the homeManager module to all managed users
            home-manager.sharedModules = [
              inputs.self.modules.homeManager.syncthing
            ];
          };
        }
        (
          lib.mkIf (lib.hasAttrByPath ["sops" "secrets"] options) (
            let
              nixosKeyOwnership = {
                owner = "syncthing";
                group = "syncthing";
                mode = "0440";
              };
            in {
              # Setup keys
              sops.secrets = {
                "syncthing/cert" = nixosKeyOwnership;
                "syncthing/key" = nixosKeyOwnership;
                "syncthing/restapi" = nixosKeyOwnership;
              };
              services.syncthing = {
                # Setup services
                cert = config.sops.secrets."syncthing/cert".path;
                key = config.sops.secrets."syncthing/key".path;
                # https://github.com/NixOS/nixpkgs/pull/401900#event-23372654453
                # apiKeyFile = config.sops.secrets."syncthing/restapi".path;
              };
            }
          )
        )
      ];
    };

    # Darwin module
    darwin.syncthing = {
      config,
      options,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        (
          lib.mkIf (lib.hasAttrByPath ["sops" "secrets"] options) (let
            darwinKeyOwnership = {
              group = "staff";
              mode = "0440";
            };
          in {
            # Provision key Ownership
            sops.secrets = {
              "syncthing/cert" = darwinKeyOwnership;
              "syncthing/key" = darwinKeyOwnership;
              "syncthing/restapi" = darwinKeyOwnership;
            };
          })
        )
        (
          lib.mkIf (lib.hasAttrByPath ["system" "mainUser"] options) {
            # We dispatch to home-manager module IF our main user is defined
            home-manager.users = lib.mkIf (config.system.mainUser != null) {
              "${config.system.mainUser}".imports = [
                # Enable syncthing for this specific user
                inputs.self.modules.generic.syncthing
                inputs.self.modules.homeManager.syncthing
                # Dispatch keys to this specific user
                inputs.self.modules.homeManager.syncthingKeyDispatch
              ];
            };
          }
        )
      ];
    };
  };
}

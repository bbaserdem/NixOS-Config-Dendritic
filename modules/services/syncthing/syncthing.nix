# Syncthing; configuration entry file
{lib, ...}: {
  den = {
    # Quirk for collecting device information across the entire fleet
    quirks = {
      syncthing-devices.description = ''
        Registered syncthing devices. (Collected with provenance)

        This quirk should contain all nodes with provenance info
        Each entry should have the following info;
        - label: internal device name used
        - name: the device name used by syncthing
        - id: public id string for the device
        - globalShare: flag to check if this node is participating in fleet share
        - {gui,transfer,discovery}Port: ports used by the node
      '';
      syncthing-folders.description = ''
        Registered syncthing folders (collected with provenance)

        Each node will emit to this quirk every folder it wants to sync, except the global sync entry.
        Each entry should have the following info;
        - type: A metadata to distinguish which type of folder is this.
        - (mediaDir): For media type folders; the media directory attrset key.
      '';
    };

    # Host schema for enabling syncthing relay
    schema.host = {
      options = {
        networking = lib.mkOption {
          type = lib.types.submodule {
            options = {
              syncthing = lib.mkOption {
                description = "Syncthing options for this host";
                default = {};
                type = lib.types.submodule {};
              };
            };
          };
        };
      };
    };

    # Base aspect naming
    aspects.syncthing = {
      name = "syncthing";
    };
  };

  # Modules
  flake.modules = {
    # Generic module for enabling syncthing on nixos or on home-manager
    generic.syncthing-settings = {lib, ...}: {
      key = "syncthing-settings#generic";
      config = {
        services.syncthing = {
          enable = true;
          settings.options = {
            urAccepted = 3;
            relaysEnabled = true;
            # Default to enabling this; settings overridden on user level
            localAnnounceEnabled = lib.mkDefault true;
          };
        };
      };
    };
    # Home-manager level syncthing settings
    homeManager.syncthing-settings = {
      lib,
      pkgs,
      ...
    }: {
      key = "syncthing-settings#homeManager";
      config = lib.mkMerge [
        (
          # Syncthing tray for linux only
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            services.syncthing.tray = {
              enable = true;
              package = pkgs.syncthingtray;
            };
          }
        )
      ];
    };
  };
}

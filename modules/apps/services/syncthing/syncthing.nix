# Syncthing; file synching solution
{inputs, ...}: {
  flake.modules = {
    # Global configuration entry
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

    # NixOS specific options
    nixos.syncthing = {lib, ...}: {
      services.syncthing = {
        # Enable relays and ports
        openDefaultPorts = true;
        relay.enable = true;

        # The dataDir option is the home directory of the syncthing users
        dataDir = "/home/syncthing";
      };

      # https://github.com/NixOS/nixpkgs/issues/338485
      # By default, nixos module doesn't have permissions for ownership change
      # This should allow the service to do ownership change though
      systemd.services.syncthing.serviceConfig = {
        # Add these capabilities
        AmbientCapabilities = [
          "CAP_CHOWN"
          "CAP_FOWNER"
        ];
        # Disable user sandboxing, or file ownership won't work
        PrivateUsers = lib.mkForce false;
      };
    };

    homeManager.syncthing = {
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
        # In linux context, we want to pass on the restapi key
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
  };
}

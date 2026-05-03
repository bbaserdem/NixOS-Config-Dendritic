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
    nixos.syncthing = {
      lib,
      config,
      ...
    }: {
      options.local.syncthing.userDirs = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = ''
          Maps usernames to their Syncthing subdirectory name.
        '';
      };
      config = {
        services.syncthing = {
          # Enable relays and ports
          openDefaultPorts = true;
          relay.enable = true;

          # The dataDir option is the home directory of the syncthing users
          dataDir = "/home/syncthing";
        };
        systemd = {
          # https://github.com/NixOS/nixpkgs/issues/338485
          # By default, nixos module doesn't have permissions for ownership change
          # This should allow the service to do ownership change though
          services.syncthing.serviceConfig = {
            # Add these capabilities
            AmbientCapabilities = [
              "CAP_CHOWN"
              "CAP_FOWNER"
            ];
            # Disable user sandboxing, or file ownership won't work
            PrivateUsers = lib.mkForce false;
          };

          # ACL provisioning to home directory
          tmpfiles.settings."10-syncthing-data"."${config.services.syncthing.dataDir}" = {
            # Set root directory ownership to syncthing
            d = {
              user = config.services.syncthing.user;
              group = config.services.syncthing.group;
              mode = "0750";
            };
            # Provision ACL access to the entire tree
            "A+".argument = "u:${config.services.syncthing.user}:rwX,m::rwX";
            "a+".argument = "d:u:${config.services.syncthing.user}:rwx,d:m::rwx";
          };
        };
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

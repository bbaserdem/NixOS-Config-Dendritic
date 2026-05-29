# Syncthing; file synching across computers
{...}: {
  # Global stignore string
  localConfig.syncthing.ignore.global = ''
    // Global stignore

    // Do not ignore any Stignore folders
    !/Stignore
    !/Stignore/*

    // Don't track thumbnaails
    .thumbnails
    .thumbnails/**

    // Don't track any VCS
    (?d).git
    (?d).gitmodules
    (?d).jj

    // OS Junk
    (?d).DS_Store
    .localized
  '';

  flake.modules = {
    # Syncthing global options

    # Global configuration entry
    generic.syncthing = {...}: {
      services.syncthing = {
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
    }: let
      cfg = config.services.syncthing;
    in {
      # NixOS only settings for the daemon
      services.syncthing = {
        # Enable
        enable = true;
        # Enable relays and ports
        openDefaultPorts = true;
        relay.enable = true;

        # The dataDir option is the home directory of the syncthing users
        dataDir = "/home/syncthing";
      };

      # Daemon settings
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

        # ACL and permission provisioning to home directory
        tmpfiles.settings."10-syncthing-data"."${cfg.dataDir}" = {
          # Set root directory ownership to syncthing
          d = {
            user = cfg.user;
            group = cfg.group;
            mode = "0750";
          };
          # Provision ACL access to the entire tree
          "A+".argument = "u:${cfg.user}:rwX,m::rwX";
          "a+".argument = "d:u:${cfg.user}:rwx,d:m::rwx";
        };
      };
    };

    # Darwin specific options; enable syncthing for the main user
    darwin.syncthing = {
      config,
      options,
      lib,
      ...
    }: {
      config =
        lib.optionalAttrs (
          (lib.hasAttrByPath ["home-manager"] options)
          && (lib.hasAttrByPath ["local" "mainUser"] options)
        ) {
          home-manager.users = lib.mkIf (config.local.mainUser != null) {
            "${config.local.mainUser}".imports = [
              ({...}: {services.syncthing.enable = true;})
            ];
          };
        };
    };

    # Home-Manager specific settings
    homeManager.syncthing = {
      pkgs,
      lib,
      ...
    } @ args: {
      config = lib.mkMerge [
        (
          # Enable syncthing HM module iff we are standalone
          lib.optionalAttrs (!(lib.hasAttrByPath ["osConfig"] args)) {
            services.syncthing.enable = true;
          }
        )
        (
          # In we are in linux, we want syncthingtray
          # TODO; Create a syncthingtray config module, and pass restapi key
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

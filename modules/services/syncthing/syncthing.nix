# Syncthing; file synching across computers
{lib, ...}: {
  config = {
    # Host setting registry for den
    den.schema.host = {
      config,
      lib,
      ...
    }: {
      options = {
        syncthing = {
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = config.syncthing.deviceId != "";
            description = ''
              Whether to enable running syncthing on this host
              Default to enabled if device ID is populated.
            '';
          };
          deviceId = lib.mkOption {
            type = lib.types.strMatching "([A-Z2-7]{7}(-[A-Z2-7]{7}){7})?";
            # 56 base32 characters, 8 dash seperated groups of 7 (or empty string)
            default = "";
            description = "Host ID in syncthing for this host";
          };
        };
      };
    };

    # Global stignore string
    localConfig.syncthing.ignore.global = ''
      // Global stignore

      // Do not ignore any Stignore folders
      !/Stignore
      !/Stignore/*

      // Do not track thumbnaails
      .thumbnails
      .thumbnails/**

      // Do not track any VCS
      (?d).git
      (?d).gitmodules
      (?d).jj

      // OS Junk, trash directories
      .Trash-*
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
        };

        # Add syncthing to users group to be able to operate with users
        users.users.${cfg.user}.extraGroups = ["users"];

        # Daemon settings
        systemd.services.syncthing.serviceConfig = {
          # https://github.com/NixOS/nixpkgs/issues/338485
          # By default, nixos module doesn't have permissions for ownership change
          # This should allow the service to do ownership change though
          # WARNING
          # This won't be taken advantage of, due to syncthing inherit ownership
          # being bugged, and not working.
          # https://github.com/syncthing/syncthing/issues/8399
          # We are switching functionality instead; but leaving the capability
          # levers in place; to go back to previousy implementation if bug is fixed

          # New files 0660 / dirs 0770; combined with setgid dirs and ignorePerms
          UMask = "0007";

          # Add these capabilities
          AmbientCapabilities = [
            "CAP_CHOWN"
            "CAP_FOWNER"
          ];

          # Disable user sandboxing, or file ownership won't work
          PrivateUsers = lib.mkForce false;
          NoNewPrivileges = lib.mkForce false;

          # Allow chown/lchown/fchownat.
          # This avoids the systemd sandbox blocking
          # copyOwnershipFromParent even when CAP_CHOWN is present
          SystemCallFilter = lib.mkForce [
            "@system-service"
            "@chown"
          ];
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
  };
}

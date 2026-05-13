# Paperless; provision folder to syncthing
{...}: {
  flake.modules = {
    # Provision the folder to syncthing in general
    generic.syncthing = {
      config,
      lib,
      ...
    }: {
      services.syncthing.settings.folders.paperless = {
        enable = lib.mkOverride 1400 false;
        label = "Paperless";
        id = "Paperless";
        # Just share with all defined devices
        devices =
          config.services.syncthing.settings.devices
          |> builtins.attrNames
          |> (lib.filter (device: device != config.networking.hostName));
        versioning = {
          type = "trashcan";
          params = {
            cleanoutDays = "60";
          };
        };
      };
    };

    # Nixos settings for the shared folder
    nixos.syncthing = {
      config,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        (
          # When paperless is present on the host
          lib.mkIf (config.services.paperless.enable == true) {
            services.syncthing.settings.folders.paperless = {
              # Enable by default
              enable = lib.mkDefault true;
              # The path is pulled from paperless media dir
              path = config.services.paperless.mediaDir;
              # This is a send only type of directory
              type = "sendonly";
              # Retain ownership of paperless, don't do syncthing
              copyOwnershipFromParent = true;
            };
            # Provision ACL read and write permissions of the media dir to syncthing
            systemd.tmpfiles.settings."20-paperless-syncthing" = {
              "${config.services.paperless.mediaDir}" = {
                "A+".argument = "u:${config.services.syncthing.user}:rwX,m::rwX";
                "a+".argument = "d:u:${config.services.syncthing.user}:rwx,d:m::rwx";
              };
            };
          }
        )
        (
          # When paperless is not present, we are just a backup folder
          lib.mkIf (config.services.paperless.enable == false) {
            services.syncthing.settings.folders.paperless = {
              # We default to a path in the syncthing home
              path = "${config.services.syncthing.dataDir}/Paperless";
              # This is a backup; we are receive only
              type = "receiveonly";
            };
          }
        )
      ];
    };

    # In standalone and darwin contexts, set paperless default path
    homeManager.syncthing = {...}: {
      services.syncthing.settings.folders.paperless = {
        path = "~/Paperless";
        type = "receiveonly";
      };
    };
  };
}

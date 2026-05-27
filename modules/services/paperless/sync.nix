# Paperless; provision folder to syncthing
{config, ...}: let
  paperlessFolder = config.localConfig.syncthing.folders.paperless;
in {
  # Register paperless folder definition with syncthing
  localConfig.syncthing.folders.paperless = {
    owner = "paperless";
    hosts = [
      # This will actually be defined on host folders instead
      # TODO; migrate this setting to each hosts' config
      # "su-ana"
    ];
    ignore = {
      global = ''
      '';
    };
  };

  flake.modules = {
    # Establish folder settings
    generic.syncthing = {
      config,
      lib,
      options,
      ...
    }: {
      services.syncthing.settings.folders.paperless = {
        # Default to receive-only, paperless module will override this
        type = lib.mkOverride 1400 "receiveonly";
        versioning = lib.mkOverride 1400 {
          type = "trashcan";
          params.cleanoutDays = "365";
        };
      };
    };

    # Nixos settings override for the shared folder
    nixos.paperless = {
      config,
      lib,
      ...
    }: {
      config =
        lib.mkIf (
          (config.services.syncthing.enable)
          && (lib.elem config.networking.hostName paperlessFolder.hosts)
        ) {
          # Overwrite syncthing config
          services.syncthing.settings.folders.paperless = {
            # We are a provider, so we are sendonly here
            type = lib.mkOverride 1200 "sendonly";
            # No versioning
            versioning = lib.mkOverride 1200 null;
            # Retain ownership of paperless, don't do syncthing
            copyOwnershipFromParent = true;
          };
          # Provision ACL read and write permissions to syncthing
          systemd.tmpfiles.settings."20-paperless-syncthing" = {
            "${config.services.paperless.exporter.directory}" = {
              "A+".argument = "u:${config.services.syncthing.user}:rX,m::rX";
              "a+".argument = "d:u:${config.services.syncthing.user}:rwx,d:m::rwx";
            };
          };
          # Let the syncthing directory be a bind mount to the actual directory
          # Set the bind mount
          fileSystems."${config.services.syncthing.settings.folders.paperless.path}" = {
            device = config.services.paperless.exporter.directory;
            fsType = "none";
            options = ["bind" "nofail"];
          };
        };
    };
  };
}

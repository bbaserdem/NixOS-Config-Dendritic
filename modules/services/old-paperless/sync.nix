# Paperless; provision folder to syncthing
{config, ...}: let
  paperlessFolder = config.localConfig.syncthing.folders.paperless;
in {
  # Only the export directory is synced;
  # Syncing is for backup purposes only, restorable via document_importer
  # Duplicates media on the paperless host but reduces workload friction
  #
  # The paperless host is sendonly; syncthing shouldn't write anything
  # And doesn't do versioning
  #
  # Every enabled host after paperless is receiveonly; backup purposes only.
  localConfig.syncthing.folders.paperless = {
    owner = "paperless";
    # Sync in place on hosts where the owner exists; backup receivers
    # place the folder under the media root as usual
    systemPath = "/home/paperless";
    hosts = [
      # This will actually be defined on host folders instead
      # TODO; migrate this setting to each hosts' config
      # "od-ata"
    ];
    ignore = {
      global = ''
        // Only sync the Export tree, not the runtime data
        /Media
        /Consume

        // Ignore transient exporter stuff
        (?d)*.tmp
      '';
    };
  };

  flake.modules = {
    # Establish folder settings for general hosts
    generic.syncthing = {lib, ...}: {
      services.syncthing.settings.folders.paperless = {
        # Default to receive-only, the paperless provider overrides this
        type = lib.mkOverride 1400 "receiveonly";
        versioning = lib.mkOverride 1400 {
          type = "trashcan";
          params.cleanoutDays = "365";
        };
      };
    };

    # Provider side settings; hosts running paperless itself
    nixos.paperless = {
      config,
      lib,
      ...
    }: let
      syncUser = config.services.syncthing.user;
      paperlessUser = config.services.paperless.user;
      paperlessGroup = config.users.users.${paperlessUser}.group;
      homeDir = config.local.paperless.homeDir;
      exporterDir = config.local.paperless.exporter.directory;
    in {
      config =
        lib.mkIf (
          (config.services.syncthing.enable)
          && (lib.elem config.networking.hostName paperlessFolder.hosts)
        ) {
          # We don't pull the physical location from the config
          # Make sure we set the correct folder
          assertions = [
            {
              assertion = homeDir == paperlessFolder.systemPath;
              message = ''
                Syncthing folder for paperless doesn't match the export directory.
                - localConfig.syncthing.folders.paperless.systemPath: (${paperlessFolder.systemPath})
                - <host>.local.paperless.homeDir: (${homeDir})
              '';
            }
            {
              assertion = lib.hasPrefix "${homeDir}/" exporterDir;
              message = ''
                Paperless exporter director must live inside the sync directory
                - localConfig.syncthing.folders.paperless.systemPath: (${paperlessFolder.systemPath})
                - <host>.local.paperless.exporter.directory: (${exporterDir})
              '';
            }
          ];

          # We are the provider; send only, no versioning
          services.syncthing.settings.folders.paperless = {
            # We are the provider, set to sendonly and no versioning.
            type = lib.mkOverride 900 "sendonly";
            versioning = lib.mkOverride 1200 null;
          };

          # Syncthing reads the tree through the paperless group,
          # Add syncthing to paperless group for read access
          users.users.${syncUser}.extraGroups = [paperlessGroup];

          # Folder root must be group writable; syncthing keeps its
          # marker and stignore file there. Setgid for group inheritance
          systemd.tmpfiles.settings."05-paperless-home"."${homeDir}".d.mode = lib.mkForce "2770";

          # Paperless defaults to UMask 0066; new files land 0600 and
          # new directories 0711, both unreadable to the group.
          # 0027 yields 0640 files and 0750 directories, "other" stays locked.
          # Applied to exporter directory.
          systemd.services.paperless-exporter.serviceConfig.UMask = lib.mkForce "0027";
        };
    };
  };
}

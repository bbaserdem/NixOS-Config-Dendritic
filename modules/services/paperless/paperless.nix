# Paperless document management
{...}: {
  flake.modules.nixos = {
    # Main paperless enable module
    paperless = {
      config,
      lib,
      ...
    }: {
      options = {
        local.paperless = {
          homeDir = lib.mkOption {
            type = lib.types.str;
            default = "/home/paperless";
            description = "Directory for paperless runtime directories";
          };
          mdnsName = lib.mkOption {
            type = lib.types.str;
            default = "paperless";
            description = "Local mDNS name prefix for the Paperless web UI";
          };
          backupName = lib.mkOption {
            type = lib.types.str;
            default = "Export";
            description = "Name of folder for state exports";
          };
          sambaHostsAllow = lib.mkOption {
            type = lib.types.string;
            default = "192.168.1.";
            description = "Samba subnet mask for paperless.";
          };
        };
      };
      config = let
        exportDir = "${config.local.paperless.homeDir}/${config.local.paperless.backupName}";
        trashDir = "${config.local.paperless.mediaDir}/trash";
      in {
        # Provisioning the home directory
        systemd.tmpfiles.settings."05-paperless-home" = {
          "${config.local.paperless.homeDir}" = {
            "d" = {
              user = config.services.paperless.user;
              group = config.users.users.${config.services.paperless.user}.group;
              mode = "0750";
            };
          };
          ${trashDir} = {
            "d" = {
              user = config.services.paperless.user;
              group = config.users.users.${config.services.paperless.user}.group;
              mode = "0750";
            };
          };
        };
        # Paperless settings
        services.paperless = {
          enable = true;
          # Directories
          dataDir = "/var/lib/paperless";
          mediaDir = "${config.local.paperless.homeDir}/Media";
          consumptionDir = "${config.local.paperless.homeDir}/Consume";
          # Runtime settings
          settings = {
            # Consumer settings
            PAPERLESS_CONSUMER_RECURSIVE = true;
            PAPERLESS_CONSUMER_IGNORE_PATTERN = [
              ".DS_STORE/*"
              "desktop.ini"
            ];
            PAPERLESS_OCR_USER_ARGS = {
              optimize = 1;
              pdfa_image_compression = "lossless";
            };
            # Enable turkish for OCR
            PAPERLESS_OCR_LANGUAGE = "eng+tur";
            # Filename in database
            PAPERLESS_FILENAME_FORMAT = "{{ created_year }}/{{ correspondent }}/{{ title }}";
            # Trash
            PAPERLESS_EMPTY_TRASH_DIR = trashDir;
          };
          # Database
          database = {};
          # Backup
          exporter = {
            enable = true;
            directory = exportDir;
            onCalendar = "03:30:00";
            settings = {
              "no-progress-bar" = true;
              "no-color" = true;
              "compare-checksums" = true;
              "delete" = true;
              "use-folder-prefix" = true;
            };
          };
        };
      };
    };
  };
}

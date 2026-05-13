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
            description = "Local DNS address prefix for the network";
          };
          lanAddress = lib.mkOption {
            type = lib.types.str;
            default = "192.168.1.50";
            description = "IP address to advertise the paperless-ngx web UI";
          };
        };
      };
      config = {
        # Provisioning the home directory
        systemd.tmpfiles.settings."05-paperless-home"."${config.local.paperless.homeDir}" = {
          d = {
            user = config.services.paperless.user;
            group = config.users.users.${config.services.paperless.user}.group;
            mode = "0750";
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
          };
        };
      };
    };
  };
}

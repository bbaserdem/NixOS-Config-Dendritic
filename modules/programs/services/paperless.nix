# Paperless document management
{...}: {
  flake.modules.nixos = {
    paperless = {...}: {
      # Set up our secret
      # sops.secrets.paperless = {};

      services.paperless = {
        enable = true;
        # passwordFile = config.sops.secrets.paperless.path;
        settings = {
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
}

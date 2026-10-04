# Paperless; set up authenticatin keys
{inputs, ...}: {
  flake.modules = {
    nixos = {
      # Main paperless enable module
      paperless = {
        config,
        lib,
        options,
        ...
      }: {
        config = lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) (
          lib.mkMerge [
            {
              # Provision the UI password
              sops.secrets."paperless/password" = {
                key = "password";
                sopsFile = inputs.self + /secrets/host/paperless.yaml;
                owner = config.services.paperless.user;
                group = config.users.users.${config.services.paperless.user}.group;
                mode = "0440";
              };
              services.paperless.passwordFile = config.sops.secrets."paperless/password".path;
            }
            (
              # Setup the HTTP routing
              lib.mkIf (config.services.nginx.enable == true) {
                # Provision the certificates
                sops.secrets = {
                  "paperless/tls/fullchain" = {
                    key = "tls/fullchain";
                    sopsFile = inputs.self + /secrets/host/paperless.yaml;
                    mode = "0400";
                    restartUnits = ["nginx.service"];
                  };
                  "paperless/tls/key" = {
                    key = "tls/key";
                    sopsFile = inputs.self + /secrets/host/paperless.yaml;
                    mode = "0400";
                    restartUnits = ["nginx.service"];
                  };
                };
                services = {
                  nginx.virtualHosts."${config.services.paperless.domain}" = {
                    forceSSL = true;
                    sslCertificate = config.sops.secrets."paperless/tls/fullchain".path;
                    sslCertificateKey = config.sops.secrets."paperless/tls/key".path;
                  };
                };
              }
            )
          ]
        );
      };
    };
  };
}

# Reverse proxy for local syncthing web-ui
{inputs, ...}: {
  flake.modules = {
    nixos.syncthing = {
      config,
      lib,
      ...
    }: {
      config = lib.mkIf (config.services.nginx.enable == true) {
        networking.hosts."127.0.0.1" = [
          "syncthing.local"
        ];

        services.nginx.virtualHosts."syncthing.local" = {
          locations."/" = {
            proxyPass = "http://${config.services.syncthing.guiAddress}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $proxy_host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };
    darwin.syncthing = {
      config,
      lib,
      options,
      ...
    }: {
      config =
        lib.optionalAttrs (
          (lib.hasAttrByPath ["local" "services" "caddy"] options)
          && (lib.hasAttrByPath ["local" "mainUser"] options)
        ) (
          lib.mkIf (
            (config.local.mainUser != null)
            && (config.local.services.caddy.enable == true)
          ) (let
            guiAddress = config.home-manager.users.${config.local.mainUser}.services.syncthing.guiAddress;
          in {
            local.services.caddy.virtualHosts."syncthing.local" = {
              listen = "http://syncthing.local";
              extraConfig = ''
                bind 127.0.0.1

                reverse_proxy ${guiAddress} {
                  header_up Host ${guiAddress}
                }
              '';
            };
            system.activationScripts.postActivation.text = lib.mkAfter ''
              if ! /usr/bin/grep -qE '^[[:space:]]*127[.]0[.]0[.]1[[:space:]].*syncthing[.]local' /etc/hosts; then
                /bin/echo '127.0.0.1 syncthing.local' >> /etc/hosts
              fi
            '';
          })
        );
    };
  };
}

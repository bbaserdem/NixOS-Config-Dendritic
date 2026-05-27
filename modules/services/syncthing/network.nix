# Reverse proxy for local mapping of syncthing web-ui
{...}: {
  flake.modules = {
    # Try to expose syncthing web-ui at syncthing.localhost

    # NixOS; use nginx if available
    nixos.syncthing = {
      config,
      lib,
      ...
    }: {
      config = lib.mkIf (config.services.nginx.enable == true) {
        networking.hosts."127.0.0.1" = [
          "syncthing.localhost"
        ];

        services.nginx.virtualHosts."syncthing.localhost" = {
          locations."/" = {
            proxyPass = "http://${config.services.syncthing.guiAddress}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };

    # Darwin; use caddy if available
    # TODO; if nix-darwin gets a module for proxies; switch to that instead of inhouse
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
          ) (
            let
              guiAddress = config.home-manager.users.${config.local.mainUser}.services.syncthing.guiAddress;
            in {
              local.services.caddy.virtualHosts."syncthing.localhost" = {
                listen = "http://syncthing.localhost";
                extraConfig = ''
                  bind 127.0.0.1

                  reverse_proxy ${guiAddress}
                '';
              };
              system.activationScripts.postActivation.text = lib.mkAfter ''
                if ! /usr/bin/grep -qE '^[[:space:]]*127[.]0[.]0[.]1[[:space:]].*syncthing[.]localhost' /etc/hosts; then
                  /bin/echo '127.0.0.1 syncthing.localhost' >> /etc/hosts
                fi
              '';
            }
          )
        );
    };
  };
}

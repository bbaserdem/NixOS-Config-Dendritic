# Paperless; set up authenticatin keys
{inputs, ...}: {
  flake.modules.nixos = {
    # Main paperless enable module
    paperless = {
      config,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        (
          # Setup local DNS resolution to paperless target.
          lib.mkIf (config.services.avahi.enable == true) {
            # Avahi publish to publish custom URL to DNS
            systemd.services.avahi-publish-paperless = {
              description = "Publish paperless-ngx via mDNS";
              after = [
                "avahi-daemon.service"
                "network-online.target"
              ];
              wants = ["network-online.target"];
              requires = ["avahi-daemon.service"];
              wantedBy = ["multi-user.target"];
              serviceConfig = {
                ExecStart = "${config.services.avahi.package}/bin/avahi-publish-address ${config.local.paperless.mdnsName}.local ${config.local.paperless.lanAddress}";
                Restart = "on-failure";
              };
            };
          }
        )
        (
          # Setup the HTTP routing
          lib.mkIf (config.services.nginx.enable == true) {
            services = {
              # Put paperless behind nginx
              paperless.settings = {
                PAPERLESS_URL = lib.mkOverride 1400 "http://${config.local.paperless.mdnsName}.local";
                PAPERLESS_USE_X_FORWARD_HOST = true;
                PAPERLESS_USE_X_FORWARD_PORT = true;
              };
              nginx.virtualHosts."${config.local.paperless.mdnsName}.local" = {
                forceSSL = lib.mkOverride 1400 false;
                enableACME = false;
                locations."/" = {
                  proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}";
                  proxyWebsockets = true;
                  extraConfig = ''
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Host $host;
                    proxy_set_header X-Forwarded-Proto $scheme;
                  '';
                };
              };
            };
          }
        )
        (
          # Setup shared consumption directory
          lib.mkIf (config.services.samba.enable == true) (let
            inboxDir = "${config.services.paperless.consumptionDir}/inbox";
            paperlessUser = config.services.paperless.user;
            paperlessGroup = config.users.users.${paperlessUser}.group;
          in {
            # Provision the subdirectory
            systemd.tmpfiles.settings."35-paperless-samba".${inboxDir} = {
              "d" = {
                user = paperlessUser;
                group = paperlessGroup;
                mode = "0770";
              };
            };

            # Set up samba shares
            services.samba.settings."paperless-inbox" = {
              path = inboxDir;
              browseable = "yes";
              "read only" = "no";
              # Simple LAN mode
              "guest ok" = "yes";
              "force user" = paperlessUser;
              "force group" = paperlessGroup;
              "create mask" = "0660";
              "directory mask" = "0770";
            };
          })
        )
      ];
    };
  };
}

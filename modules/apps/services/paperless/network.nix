# Paperless; set up authenticatin keys
{inputs, ...}: {
  flake.modules.nixos = {
    # Main paperless enable module
    paperless = {
      config,
      lib,
      pkgs,
      ...
    }: {
      config = lib.mkMerge [
        (
          # Setup local DNS resolution for paperless.local.
          lib.mkIf (config.services.avahi.enable) {
            systemd.services.avahi-publish-paperless = {
              description = "Publish paperless-ngx via mDNS";
              after = [
                "avahi-daemon.service"
                "network-online.target"
              ];
              wants = ["network-online.target"];
              requires = ["avahi-daemon.service"];
              wantedBy = ["multi-user.target"];
              path = [
                config.services.avahi.package
                pkgs.gawk
                pkgs.iproute2
              ];
              script = ''
                ip="$(
                  ip -4 route get 1.1.1.1 \
                    | awk '{ for (i = 1; i <= NF; i++) if ($i == "src") print $(i + 1) }'
                )"

                if [ -z "$ip" ]; then
                  echo "Could not determine LAN IPv4 address for paperless mDNS publication" >&2
                  exit 1
                fi

                exec avahi-publish-address ${config.local.paperless.mdnsName}.local "$ip"
              '';
              serviceConfig = {
                Restart = "on-failure";
              };
            };
          }
        )
        (
          # Setup HTTP routing through the Paperless NixOS module.
          lib.mkIf (config.services.nginx.enable) {
            services = {
              paperless = {
                configureNginx = true;
                domain = "${config.local.paperless.mdnsName}.local";
                settings = {
                  PAPERLESS_USE_X_FORWARD_HOST = true;
                  PAPERLESS_USE_X_FORWARD_PORT = true;
                };
              };
              nginx.virtualHosts."${config.services.paperless.domain}" = {
                enableACME = false;
              };
            };
          }
        )
        (
          # Setup shared consumption directory
          lib.mkIf (config.services.samba.enable) (let
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
              "hosts allow" = config.local.paperless.sambaHostsAllow;
              "hosts deny" = "0.0.0.0/0";
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

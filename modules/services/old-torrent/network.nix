# QBittorrent networking settings
{config, ...}: let
  torrentCfg = config.localConfig.torrent;
in {
  flake.modules.nixos.service-torrent = {
    config,
    lib,
    ...
  }: let
    hostCfg = config;
  in {
    config = lib.mkMerge [
      {
        # Dispatch network firewall and settings inside the container
        containers."${torrentCfg.name}" = {
          # Container settings
          privateNetwork = true;
          enableTun = true;

          # Networking for host-container
          hostAddress = torrentCfg.hostAddress;
          localAddress = torrentCfg.localAddress;

          # Configuration
          config = {...}: {
            networking = {
              # General networking settings
              hostName = "${hostCfg.networking.hostName}-${torrentCfg.name}";
              useDHCP = false;
              enableIPv6 = false;
              nameservers = torrentCfg.vpn.dns;
              wg-quick.interfaces.${torrentCfg.vpn.interface} = {
                configFile = "/run/secrets/wireguard.conf";
              };

              # Firewall as killswitch
              firewall.enable = false;
              nftables = {
                enable = true;
                flushRuleset = true;
                ruleset = ''
                  table inet torrent_killswitch {
                    chain input {
                      type filter hook input priority 0; policy drop;

                      iifname "lo" accept
                      ct state established,related accept

                      # qBittorrent Web UI from the host-side veth only.
                      ip saddr ${torrentCfg.hostAddress} tcp dport ${toString torrentCfg.uiPort} accept

                      # Optional diagnostics from host.
                      ip saddr ${torrentCfg.hostAddress} icmp type echo-request accept
                    }

                    chain output {
                      type filter hook output priority 0; policy drop;

                      oifname "lo" accept
                      ct state established,related accept

                      # Only allow the WireGuard handshake outside the tunnel.
                      ip daddr ${torrentCfg.vpn.endpoint.ip} udp dport ${toString torrentCfg.vpn.endpoint.port} oifname "eth0" accept

                      # All application traffic must leave through the VPN.
                      oifname "${torrentCfg.vpn.interface}" accept
                    }

                    chain forward {
                      type filter hook forward priority 0; policy drop;
                    }
                  }
                '';
              };
            };
          };
        };
      }
      (
        # Reverse proxy setup
        lib.mkIf (config.services.nginx.enable) {
          services.nginx.virtualHosts."${torrentCfg.name}.local" = {
            enableACME = false;
            locations."/" = {
              proxyPass = "http://${torrentCfg.localAddress}:${toString torrentCfg.uiPort}";
              proxyWebsockets = true;
            };
          };
        }
      )
      (
        # Publish address to mdns
        lib.mkIf (config.services.avahi.enable) {
        }
      )
    ];
  };
}

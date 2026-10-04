# Flake-Parts setup for the vpn torrent container
{
  lib,
  config,
  ...
}: {
  options = {
    localConfig.torrent = {
      # Global application of ignore files
      uiPort = lib.mkOption {
        type = lib.types.int;
        description = "Port to serve the web UI";
        default = 8081;
      };
      id = lib.mkOption {
        type = lib.types.int;
        description = "User and group ID for the torrent user";
        default = 973;
      };
      path = lib.mkOption {
        type = lib.types.str;
        description = "Target home directory for the torrent container";
        default = "/home/torrent";
      };
      torrentPort = lib.mkOption {
        type = lib.types.int;
        description = "Port inside the VPN namespace";
        default = 51413;
      };
      # Global declaration of all hosts
      name = lib.mkOption {
        type = lib.types.str;
        description = "URL to advertise to local network";
        default = "torrent";
      };
      # Local addresses
      hostAddress = lib.mkOption {
        type = lib.types.str;
        description = "Host-side address for container";
        default = "10.231.10.1";
      };
      # Local addresses
      localAddress = lib.mkOption {
        type = lib.types.str;
        description = "Container-side address";
        default = "10.231.10.2";
      };
      # VPN backend
      vpn = {
        provider = lib.mkOption {
          type = lib.types.enum [
            "mullvad"
            "airvpn"
          ];
          description = ''
            VPN provider to be used in the container.
            one of; mullvad, airvpn
          '';
          default = "mullvad";
        };
        interface = lib.mkOption {
          type = lib.types.str;
          description = "VPN interface name to use";
          default = "wg-torrent";
        };
        dns = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "DNS server to use inside container";
          default = [
            "10.64.0.1"
          ];
        };
        endpoint = {
          ip = lib.mkOption {
            type = lib.types.str;
            description = "Torrent endpoint IP address";
          };
          port = lib.mkOption {
            type = lib.types.int;
            description = "Torrent endpoint port";
            default = 51820;
          };
        };
      };
    };
  };
}

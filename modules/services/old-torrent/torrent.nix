# QBittorrent nixos container with vpn isolation
{config, ...}: let
  torrentCfg = config.localConfig.torrent;
in {
  flake.modules.nixos.service-torrent = {...}: {
    config = {
      # Setup the user running the container on the host
      users = {
        groups.torrent = {
          gid = torrentCfg.id;
        };
        users.torrent = {
          uid = torrentCfg.id;
          group = "torrent";
          isSystemUser = true;
        };
      };

      containers."${torrentCfg.name}" = {
        # Container settings
        autoStart = true;

        # Configuration
        config = {...}: {
          # Set up users' uid and gid
          users = {
            groups.qbittorrent.gid = torrentCfg.id;
            users.qbittorrent.uid = torrentCfg.id;
          };

          services.qbittorrent = {
            enable = true;
            user = "qbittorrent";
            group = "qbittorrent";
            webuiPort = torrentCfg.uiPort;
            torrentingPort = torrentCfg.torrentPort;
            profileDir = "/srv/media/config";

            serverConfig = {
              LegalNotice.Accepted = true;

              Preferences = {
                WebUI = {
                  Address = "0.0.0.0";
                  Port = torrentCfg.uiPort;
                  HostHeaderValidation = false;
                };

                Connection = {
                  PortRangeMin = torrentCfg.torrentPort;
                  UPnP = false;
                  Interface = torrentCfg.vpn.interface;
                  InterfaceName = torrentCfg.vpn.interface;
                };

                Downloads = {
                  SavePath = "/srv/media/downloads/complete/";
                  TempPath = "/srv/media/downloads/incomplete/";
                  TempPathEnabled = true;
                };
              };
            };
          };
        };
      };
    };
  };
}

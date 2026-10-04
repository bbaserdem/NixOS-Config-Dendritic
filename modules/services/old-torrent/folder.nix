# The shared folder for torrent
{config, ...}: let
  torrentCfg = config.localConfig.torrent;
in {
  flake.modules.nixos.service-torrent = {...}: {
    # Set up directories for torrenting
    systemd.tmpfiles.settings."40-torrent-folders" = let
      folderConf = {
        user = "torrent";
        group = "torrent";
        mode = "0770";
      };
    in {
      "${torrentCfg.path}".d = folderConf;
      "${torrentCfg.path}/downloads".d = folderConf;
      "${torrentCfg.path}/downloads/incomplete".d = folderConf;
      "${torrentCfg.path}/downloads/complete".d = folderConf;
      "${torrentCfg.path}/config".d = folderConf;
    };

    containers."${torrentCfg.name}" = {
      bindMounts = {
        "/srv/media" = {
          hostPath = "${torrentCfg.path}";
          mountPoint = "/srv/media";
          isReadOnly = false;
        };
      };
    };
  };
}

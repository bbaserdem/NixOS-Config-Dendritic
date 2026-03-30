# Take over the paperless daemon
{...}: {
  flake.modules.nixos.batuhan = {config, ...}: {
    services.paperless = let
      hmConfig = config.home-manager.users.batuhan;
    in {
      dataDir = "${hmConfig.xdg.userDirs.documents}/Paperless";
      mediaDir = "${hmConfig.xdg.userDirs.documents}/Paperless/Media";
      consumptionDir = "${hmConfig.xdg.userDirs.extraConfig.XDG_STAGING_DIR}/Paperless";
      consumptionDirIsPublic = false;
      user = "batuhan";
      settings = {
        PAPERLESS_ADMIN_USER = "batuhan";
      };
    };
  };
}

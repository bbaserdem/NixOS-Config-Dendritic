# Listenbrainz scrobbling
# Darwin doesn't have daemon implementation, need to bake it in eventually
{...}: {
  flake.modules.home-manager.listenbrainz = {config, ...}: {
    # Load token
    # sops.secrets.listenbrainz = {};

    # Set scrobbler
    services.listenbrainz-mpd = {
      enable = true;
      settings = {
        submission = {
          # token_file = config.sops.secrets.listenbrainz.path;
          cache_file = "${config.xdg.cacheHome}/mpd/listenbrainz-mpd-cache.sqlite3";
        };
      };
    };
  };
}

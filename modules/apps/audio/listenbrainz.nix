# Listenbrainz scrobbling
# Darwin doesn't have daemon implementation, would need to bake it in eventually
{...}: {
  flake.modules.homeManager.mpd = {config, ...}: {
    # Enable scrobbler
    services.listenbrainz-mpd = {
      enable = true;
      settings = {
        submission = {
          cache_file = "${config.xdg.cacheHome}/mpd/listenbrainz-mpd-cache.sqlite3";
        };
      };
    };
  };
}

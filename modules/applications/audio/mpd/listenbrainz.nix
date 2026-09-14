# Listenbrainz scrobbling
# TODO: Build darwin daemon for this; probably submit to home-manager as PR
{...}: {
  flake.modules.homeManager.mpd-listenbrainz = {
    config,
    lib,
    options,
    ...
  }: {
    key = "mpd-listenbrainz#homeManager";
    config = lib.mkMerge [
      {
        # Enable scrobbler
        services.listenbrainz-mpd = {
          enable = true;
          settings = {
            submission = {
              cache_file = "${config.xdg.cacheHome}/mpd/listenbrainz-mpd-cache.sqlite3";
            };
          };
        };
      }
      (
        # Link secret if sops secrets are available in the environment
        lib.optionalAttrs (options ? sops) {
          services.listenbrainz-mpd.settings =
            lib.mkIf
            (config.sops.secrets ? "musicbrainz/listenbrainz-token")
            {
              submission.token_file =
                config.sops.secrets."musicbrainz/listenbrainz-token".path;
            };
        }
      )
    ];
  };
}

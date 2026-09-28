# Configuring MPD for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    config,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      {
        # MPD configuration
        services = {
          mpd = {
            musicDirectory = "${config.home.homeDirectory}/Music";
            playlistDirectory = "${config.home.homeDirectory}/Music/Playlists";
          };
        };
      }
      (
        lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options)
        {
          # Load secret key
          sops.secrets."musicbrainz/listenbrainz-token" = {};
          # Listenbrainz credentials
          services.listenbrainz-mpd.settings.submission.token_file = config.sops.secrets."musicbrainz/listenbrainz-token".path;
        }
      )
    ];
  };
}

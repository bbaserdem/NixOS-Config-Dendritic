# Musicbrainz configuration for beets
{...}: {
  flake.modules.homeManager.wolframite = {
    config,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.beets.settings = {
          plugins = [
            "musicbrainz"
            "mbcollection"
            "mbsync"
            "listenbrainz"
          ];
          # MusicBrainz import settings
          musicbrainz = {
            search_limit = 10;
            extra_tags = [
              "year"
              "catalognum"
              "country"
              "media"
              "label"
            ];
            genres = true;
            external_ids = {
              discogs = true;
              bandcamp = true;
            };
          };
          # Collection upload settings
          mbcollection = {
            auto = false;
            remove = false;
          };
        };
      }
      (
        # Musicbrainz credentials to be merged to the main config
        lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) (let
          yamlName = "beets-musicbrainz-credentials.yaml";
        in {
          # Create yaml file
          sops.templates."${yamlName}" = {
            mode = "0400";
            content = ''
              listenbrainz:
                username: |-
                  ${config.sops.placeholder."musicbrainz/user"}
                token: |-
                  ${config.sops.placeholder."musicbrainz/listenbrainz-token"}
              musicbrainz:
                user: |-
                  ${config.sops.placeholder."musicbrainz/user"}
                email: |-
                  ${config.sops.placeholder."musicbrainz/email"}
                pass: |-
                  ${config.sops.placeholder."musicbrainz/pass"}
            '';
          };
          # Import yaml file in beets config
          programs.beets.settings.include = [
            config.sops.templates."${yamlName}".path
          ];
        })
      )
    ];
  };
}

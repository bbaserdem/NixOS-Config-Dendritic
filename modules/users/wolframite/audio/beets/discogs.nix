# Discogs config for beets
{...}: {
  flake.modules.homeManager.wolframite = {
    config,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      (
        # Discogs credentials to be merged to the main config
        lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) (let
          yamlName = "beets-discogs-credentials.yaml";
        in {
          sops.templates."${yamlName}" = {
            mode = "0400";
            content = ''
              discogs:
                user_token: |-
                  ${config.sops.placeholder."discogs/token"}
            '';
          };
          # Import yaml file in beets config
          programs.beets.settings.include = [
            config.sops.templates."${yamlName}".path
          ];
        })
      )
      {
        programs.beets.settings = {
          plugins = [
            "discogs"
          ];

          # Discogs settings
          discogs = {
            index_tracks = false;
            strip_disambiguation = true;
            extra_tags = [
              "barcode"
              "catalognum"
              "country"
              "label"
              "media"
              "year"
            ];
            anv = {
              artist_credit = true;
              artist = false;
              album_artist = false;
            };
          };
        };
      }
    ];
  };
}

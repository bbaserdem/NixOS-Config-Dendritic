# Load sops-nix music file secrets
{inputs, ...}: {
  flake.modules.homeManager.wolframite = {
    lib,
    options,
    ...
  }: {
    config = lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) {
      sops = {
        # Load secrets
        secrets = let
          cfg = {
            sopsFile = inputs.self + /secrets/user/wolframite/secrets.yaml;
          };
        in {
          "musicbrainz/user" = cfg;
          "musicbrainz/pass" = cfg;
          "musicbrainz/email" = cfg;
          "musicbrainz/listenbrainz-token" = cfg;
          "discogs/token" = cfg;
        };
      };
    };
  };
}

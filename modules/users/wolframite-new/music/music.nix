# Set the beets package and self-plugin
{
  inputs,
  den,
  ...
}: {
  # User aspect that loads in music related settings
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.music
      ];

      # Music aspect; parametric
      provides.music = {
        host,
        user,
      }: {
        name = "wolframite/music(${user.userName}@${host.name})";
        homeManager = {
          pkgs,
          lib,
          options,
          config,
          ...
        }: {
          # Beets is complicated; make it's own module
          imports = with inputs.self.modules.homeManager; [
            wolframite-beets
            wolframite-fluidsynth
            wolframite-mpd
          ];
          # Several configuration options
          config = lib.mkMerge [
            ( # Pull secrets for audio services
              lib.optionalAttrs (options ? sops) {
                sops.secrets =
                  lib.genAttrs
                  [
                    "musicbrainz/user"
                    "musicbrainz/pass"
                    "musicbrainz/email"
                    "musicbrainz/listenbrainz-token"
                    "discogs/token"
                  ]
                  (_: {});
              }
            )
          ];
        };
      };
    };
  };
}

# Musicbrainz configuration for beets
#
{...}: {
  flake.modules.homeManager.batuhan = {config, ...}: {
    # Pull our musicbrainz password from encrypted secret
    #sops.secrets.musicbrainz = {};

    programs.beets.settings = {
      plugins = [
        "musicbrainz"
        "mbcollection"
        "mbsync"
      ];
      musicbrainz = {
        searchlimit = 10;
        extra_tags = [
          "year"
          "catalognum"
          "country"
          "media"
          "label"
        ];
        genre = true;
        external_ids = {
          discogs = "yes";
          bandcamp = "yes";
          deezer = "yes";
        };
        user = "silverbluep";
        #pass = "!include ${config.sops.secrets.musicbrainz.path}";
      };
    };
  };
}

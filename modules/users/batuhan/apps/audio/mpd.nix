# Configuring MPD for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    config,
    ...
  }: let
    # userDirs is only allowed on linux
    srcDir =
      if pkgs.stdenv.hostPlatform.isLinux
      then config.xdg.userDirs.music
      else "${config.home.homeDirectory}/Media/Music";
  in {
    config = {
      # Listenbrainz token
      # sops.secrets.listenbrainz = {};

      services = {
        # MPD configuration
        mpd = {
          musicDirectory = srcDir;
          playlistDirectory = "${srcDir}/Playlists";
          network = {
            listenAddress = "localhost";
            port = 6600;
          };
        };
        # Listenbrainz credentials
        listenbrainz-mpd = {
          # token_file = config.sops.secrets.listenbrainz.path;
        };
      };
    };
  };
}

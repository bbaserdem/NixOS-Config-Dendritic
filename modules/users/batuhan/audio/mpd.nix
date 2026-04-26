# Configuring MPD for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    config,
    lib,
    options,
    ...
  }: let
    # userDirs is only allowed on linux
    srcDir =
      if pkgs.stdenv.hostPlatform.isLinux
      then config.xdg.userDirs.music
      else "${config.home.homeDirectory}/Media/Music";
  in {
    config = lib.mkMerge [
      {
        # MPD configuration
        services = {
          mpd = {
            musicDirectory = srcDir;
            playlistDirectory = "${srcDir}/Playlists";
            network = {
              listenAddress = "localhost";
              port = 6600;
            };
          };
        };
      }
      (
        lib.mkIf (lib.hasAttrByPath ["sops" "secrets"] options)
        {
          # Load secret key
          sops.secrets."listenbrainz" = {};
          # Listenbrainz credentials
          services.listenbrainz-mpd.settings.submission.token_file = config.sops.secrets."listenbrainz".path;
        }
      )
    ];
  };
}

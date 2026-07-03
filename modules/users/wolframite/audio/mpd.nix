# Configuring MPD for wolframite
{inputs, ...}: {
  flake.modules.homeManager.wolframite = {
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
      else "${config.home.homeDirectory}/Music";
  in {
    config = lib.mkMerge [
      {
        # MPD configuration
        services = {
          mpd = {
            musicDirectory = srcDir;
            playlistDirectory = "${srcDir}";
            network = {
              listenAddress = "localhost";
              port = 6600;
            };
          };
        };
      }
      (
        lib.optionalAttrs (lib.hasAttrByPath ["sops"] options)
        {
          # Listenbrainz credentials
          services.listenbrainz-mpd.settings.submission.token_file =
            config.sops.secrets."musicbrainz/listenbrainz-token".path;
        }
      )
      (
        let
          homeDir = config.home.homeDirectory;
          mpdDir = config.services.mpd.musicDirectory;
        in
          # Dispatch .mpdignore file
          (
            lib.mkIf (lib.hasPrefix "${homeDir}/" mpdDir) {
              home.file."${inputs.self.lib.stripRootDir homeDir mpdDir}/.mpdignore".text = ''
                Staging
                Sort
                Unsorted
              '';
            }
          )
      )
    ];
  };
}

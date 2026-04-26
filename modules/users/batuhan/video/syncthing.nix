# Wolframite syncthing videos folder configuration
{...}: {
  flake.modules = {
    # Folder definitions for our user to share
    generic.syncthing = {lib, ...}: {
      services.syncthing.settings.folders = {
        wolframite-video = {
          enable = lib.mkOptionDefault false;
          label = "Wolframite Video";
          id = "Wolframite_Video";
          type = "sendreceive";
          versioning = {
            type = "trashcan";
            params = {cleanoutDays = "60";};
          };
        };
      };
    };

    # Context-dependent folder locations
    homeManager.syncthing = {pkgs, ...}: {
      services.syncthing.settings.folders = {
        wolframite-video.path =
          if pkgs.stdenv.hostPlatform.isDarwin
          then "~/Movies"
          else "~/Videos";
      };
    };
    nixos.syncthing = {config, ...}: {
      services.syncthing.settings.folders = {
        wolframite-video.path = "${config.syncthing.dataDir}/Wolframite/Videos";
      };
    };
  };
}

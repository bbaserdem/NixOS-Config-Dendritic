# Wolframite syncthing music folder configuration
{...}: {
  flake.modules = {
    # Folder definitions for our user to share
    generic.syncthing = {lib, ...}: {
      services.syncthing.settings.folders.wolframite-music = {
        enable = lib.mkOverride 1400 false;
        label = "Wolframite Music";
        id = "Wolframite_Music";
        type = "sendreceive";
        versioning = {
          type = "trashcan";
          params = {cleanoutDays = "60";};
        };
      };
    };

    # Context-dependent folder locations
    homeManager.syncthing = {...}: {
      services.syncthing.settings.folders.wolframite-music = {
        path = "~/Music";
      };
    };
    nixos.syncthing = {config, ...}: {
      services.syncthing.settings.folders.wolframite-music = {
        path = "${config.syncthing.dataDir}/Wolframite/Music";
      };
    };
  };
}

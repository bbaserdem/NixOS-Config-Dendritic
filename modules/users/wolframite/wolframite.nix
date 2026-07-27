# Initialize this user
{
  config,
  den,
  ...
}: let
  factory = config.factory;
in {
  den = let
    wolframiteDirs = {
      mediaDirs = {
        # XDG directories
        documents.location = "Documents";
        download.location = "Downloads";
        music.location = "Music";
        pictures.location = "Pictures";
        projects.location = "Projects";
        publicShare.location = "Shared/Public";
        videos.location = "Videos";
        # Android sync
        android.location = "Shared/Android";
      };
    };
  in {
    # Default for all wolframite user entity records
    schema = {
      user = {
        user,
        lib,
        ...
      }: {
        config = lib.mkIf (user.userName == "wolframite") wolframiteDirs;
      };
      home = {
        home,
        lib,
        ...
      }: {
        config = lib.mkIf (home.userName == "wolframite") wolframiteDirs;
      };
    };

    # Initialize the media folders to syncthing
    syncthingFolders = factory.mkSyncthingMediaFolders "wolframite" [
      "documents"
      "music"
      "pictures"
      "videos"
      "download"
      "projects"
      "android"
    ];

    # User aspect
    aspects.wolframite = {
      # Auto-includes
      includes = [
        den.aspects.wolframite.icons
      ];

      # Icons aspect
      icons = factory.mkUserIconAspect {
        default = "wolframite_lensa";
        hosts = {
          yel-ana = "wolframite_headshot";
        };
      };
    };
  };
}

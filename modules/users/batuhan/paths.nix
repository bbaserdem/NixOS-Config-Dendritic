# Configuring user paths
{...}: {
  flake.modules.homeManager.batuhan = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkMerge [
      {
        # XDG paths
        xdg = {
          # Enables this feature
          enable = true;
          # Directories
          cacheHome = "${config.home.homeDirectory}/.cache";
          configHome = "${config.home.homeDirectory}/.config";
          dataHome = "${config.home.homeDirectory}/.local/share";
          stateHome = "${config.home.homeDirectory}/.local/state";
        };
        # Flake location
        home.sessionVariables = {
          NH_FLAKE = "${config.home.homeDirectory}/Projects/SystemConfigFlake";
          NH_OS_FLAKE = "${config.home.homeDirectory}/Projects/SystemConfigFlake";
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # User dirs are only available in Linux
          xdg.userDirs = {
            enable = true;
            createDirectories = true;
            desktop = "${config.home.homeDirectory}/Desktop";
            documents = "${config.home.homeDirectory}/Media/Documents";
            music = "${config.home.homeDirectory}/Media/Music";
            pictures = "${config.home.homeDirectory}/Media/Pictures";
            templates = "${config.home.homeDirectory}/Media/Templates";
            videos = "${config.home.homeDirectory}/Media/Videos";
            publicShare = "${config.home.homeDirectory}/Shared/Public";
            download = "${config.home.homeDirectory}/Sort/Downloads";
            extraConfig = {
              XDG_MEDIA_DIR = "${config.home.homeDirectory}/Media";
              XDG_NOTES_DIR = "${config.home.homeDirectory}/Media/Notes";
              XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
              XDG_STAGING_DIR = "${config.home.homeDirectory}/Sort";
              XDG_PHONE_DIR = "${config.home.homeDirectory}/Shared/Android";
            };
          };

          # Add the bookmarks to file browser
          gtk.gtk3.bookmarks = [
            "file://${config.xdg.userDirs.documents}"
            "file://${config.xdg.userDirs.music}"
            "file://${config.xdg.userDirs.pictures}"
            "file://${config.xdg.userDirs.videos}"
            "file://${config.xdg.userDirs.extraConfig.XDG_MEDIA_DIR}"
            "file://${config.xdg.userDirs.extraConfig.XDG_PHONE_DIR}"
            "file://${config.xdg.userDirs.download}"
            "file://${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}"
          ];

          # Aliases to navigate quickly
          home.shellAliases = {
            cd-projs = "cd ${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}";
            cd-notes = "cd ${config.xdg.userDirs.extraConfig.XDG_NOTES_DIR}";
            cd-media = "cd ${config.xdg.userDirs.extraConfig.XDG_MEDIA_DIR}";
            cd-music = "cd ${config.xdg.userDirs.music}";
            cd-image = "cd ${config.xdg.userDirs.pictures}";
            cd-video = "cd ${config.xdg.userDirs.videos}";
            cd-downl = "cd ${config.xdg.userDirs.download}";
          };
        }
      )
    ];
  };
}

# Configuring user paths
{...}: {
  # TODO; Adjust to new projects settings in 26.05
  localConfig.users.wolframite.xdgDirs = {
    documents = "Documents";
    music = "Music";
    pictures = "Pictures";
    videos = "Videos";
    download = "Downloads";
    desktop = "Desktop";
    templates = "Templates";
    publicShare = "Shared/Public";
    # projects = "Projects";
  };
  flake.modules.homeManager.wolframite = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkMerge [
      {
        # XDG paths
        xdg = {
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
          # TODO: Figure out a better solution for the android directory
          xdg.userDirs.extraConfig = {
            XDG_PHONE_DIR = "${config.home.homeDirectory}/Shared/Android";
          };
          # Add the bookmarks to file browser(s)
          gtk.gtk3.bookmarks = [
            "file://${config.xdg.userDirs.documents}"
            "file://${config.xdg.userDirs.music}"
            "file://${config.xdg.userDirs.pictures}"
            "file://${config.xdg.userDirs.videos}"
            "file://${config.xdg.userDirs.download}"
            # "file://${config.xdg.userDirs.projects}"
          ];

          # Aliases to navigate quickly
          home.shellAliases = {
            ## cd-projs = "cd ${config.xdg.userDirs.projects}";
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

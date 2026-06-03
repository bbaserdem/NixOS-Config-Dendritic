# Configuring user paths
{...}: {
  localConfig.users.wolframite.xdgDirs = {
    documents = "Documents";
    music = "Music";
    pictures = "Pictures";
    videos = "Videos";
    download = "Downloads";
    desktop = "Desktop";
    templates = "Templates";
    publicShare = "Shared/Public";
    projects = "Projects";
  };
  flake.modules.homeManager.wolframite = {
    config,
    lib,
    pkgs,
    ...
  }: let
    flakeDir = "${config.xdg.userDirs.projects}/SystemConfigFlake";
  in {
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
          NH_FLAKE = flakeDir;
          NH_OS_FLAKE = flakeDir;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # TODO: Figure out a better solution for the android directory
          xdg.userDirs.extraConfig = {
            PHONE = "${config.home.homeDirectory}/Shared/Android";
            FLAKE = flakeDir;
          };
          # Add the bookmarks to file browser(s)
          gtk.gtk3.bookmarks = [
            "file://${config.xdg.userDirs.documents}"
            "file://${config.xdg.userDirs.music}"
            "file://${config.xdg.userDirs.pictures}"
            "file://${config.xdg.userDirs.videos}"
            "file://${config.xdg.userDirs.download}"
            "file://${config.xdg.userDirs.projects}"
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

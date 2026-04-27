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
          # Other user dirs are set by the sync module by default
          xdg.userDirs = {
            enable = true;
            createDirectories = true;
            # These are set by the sync module, allow overriding them
            documents = lib.mkOverride 1250 "${config.home.homeDirectory}/Documents";
            music = lib.mkOverride 1250 "${config.home.homeDirectory}/Music";
            pictures = lib.mkOverride 1250 "${config.home.homeDirectory}/Pictures";
            videos = lib.mkOverride 1250 "${config.home.homeDirectory}/Videos";
            download = lib.mkOverride 1250 "${config.home.homeDirectory}/Downloads";
            # These are defaults
            desktop = "${config.home.homeDirectory}/Desktop";
            templates = "${config.home.homeDirectory}/Templates";
            publicShare = "${config.home.homeDirectory}/Shared/Public";
            # Some extras that I may use
            extraConfig = {
              XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
              XDG_PHONE_DIR = "${config.home.homeDirectory}/Shared/Android";
            };
          };

          # Add the bookmarks to file browser
          gtk.gtk3.bookmarks = [
            "file://${config.xdg.userDirs.documents}"
            "file://${config.xdg.userDirs.music}"
            "file://${config.xdg.userDirs.pictures}"
            "file://${config.xdg.userDirs.videos}"
            "file://${config.xdg.userDirs.download}"
            "file://${config.xdg.userDirs.extraConfig.XDG_PHONE_DIR}"
            "file://${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}"
          ];

          # Aliases to navigate quickly
          home.shellAliases = {
            cd-projs = "cd ${config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR}";
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

# Configuring user paths
{...}: {
  localConfig.users.sbp.xdgDirs = {
    projects = "Projects";
  };
  flake.modules.homeManager.sbp = {
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
          FLAKE = "git+https://codeberg.org/baserdemb/SystemConfigFlake.git";
          FLAKE_REMOTE = "https://codeberg.org/baserdemb/SystemConfigFlake.git";
          FLAKE_BRANCH = "main";
          NH_FLAKE = flakeDir;
          NH_OS_FLAKE = flakeDir;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          xdg.userDirs.extraConfig.FLAKE = flakeDir;
          gtk.gtk3.bookmarks = [
            "file://${config.xdg.userDirs.projects}"
            "file://${flakeDir}"
          ];
          # Aliases for flake
          home = {
            shellAliases.flake-cd = "cd ${flakeDir}";
            packages = [
              (pkgs.writeShellApplication {
                name = "flake-sync";
                runtimeInputs = with pkgs; [
                  coreutils
                  git
                ];
                text = ''
                  set -euo pipefail

                  : "''${NH_FLAKE:?NH_FLAKE is not set}"
                  : "''${FLAKE_REMOTE:?FLAKE_REMOTE is not set}"

                  repo="''${FLAKE_REMOTE}"
                  branch="''${FLAKE_BRANCH:-main}"

                  if [ -d "$NH_FLAKE/.git" ]; then
                    git -C "$NH_FLAKE" fetch --prune origin
                    git -C "$NH_FLAKE" pull --ff-only origin "$branch"
                    exit 0
                  fi

                  if [ -e "$NH_FLAKE" ]; then
                    printf '%s\n' "$NH_FLAKE exists but is not a git repository" >&2
                    exit 1
                  fi

                  mkdir -p "$(dirname "$NH_FLAKE")"
                  git clone --branch "$branch" "$repo" "$NH_FLAKE"
                '';
              })
            ];
          };
        }
      )
    ];
  };
}

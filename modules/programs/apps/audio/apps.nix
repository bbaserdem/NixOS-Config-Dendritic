# Music related apps
{...}: {
  flake.modules = {
    # Install swmpc in darwin contexts for mpd
    darwin = {
      # Install swmpc from app store
      mpd = {...}: {
        homebrew = {
          masApps = {
            "swmpc" = 6743818735;
          };
        };
      };
      # Audio player from brew
      audio = {...}: {
        homebrew = {
          casks = [
            "foobar2000"
          ];
        };
      };
    };

    # Apps to install
    homeManager.audio = {
      pkgs,
      lib,
      ...
    }: {
      # Install these apps to userspace
      config = lib.mkMerge [
        {
          home.packages = with pkgs; [
            streamrip # Music downloader
            audacity # Audio editor
            musescore # Score editing
            chromaprint # Calculate acoustic id
          ];
        }
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            home.packages = with pkgs; [
              cantata
              prejectm-sdl-cpp # Broken on darwin
            ];
          }
        )
      ];
    };
  };
}

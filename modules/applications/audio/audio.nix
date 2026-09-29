# Audio tools; base aspect
{inputs, ...}: {
  # Dispatch modules in aspect
  den = {
    aspects.audio = {
      # Base aspect
      name = "audio";
      # Global dispatch
      provides.to-users = {
        host,
        user,
      }: {
        name = "audio(${user.userName}@${host.name})";
        # Modules to load for full audio management collection
        homeManager = {...}: {
          imports = with inputs.self.modules.homeManager; [
            audio-utilities
          ];
        };
      };
      # Applications
      provides.tenacity = {
        name = "audio/tenacity";
        provides.to-users = {
          host,
          user,
        }: {
          name = "audio/tenacity(${user.userName}@${host.name})";
          # Modules to load for full audio management collection
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.tenacity
            ];
          };
        };
      };
      provides.musescore = {
        name = "audio/musescore";
        provides.to-users = {
          host,
          user,
        }: {
          name = "audio/musescore(${user.userName}@${host.name})";
          # Modules to load for full audio management collection
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.musescore
            ];
          };
        };
      };
      provides.foobar = {
        name = "audio/foobar";
        provides.to-users = {
          host,
          user,
        }: {
          name = "audio/foobar(${user.userName}@${host.name})";
          # Modules to load for full audio management collection
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.foobar
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    homeManager = {
      # Utilities to help with music files
      audio-utilities = {
        pkgs,
        lib,
        ...
      }: {
        key = "audio-utilities#homeManager";
        # Install these apps to userspace
        config = lib.mkMerge [
          {
            home.packages = with pkgs; [
              streamrip # Music downloader
              whipper # CD ripping utility
              chromaprint # Calculate acoustic id
            ];
          }
          (
            # Broken on darwin, install to linux only
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              home.packages = with pkgs; [
                projectm-sdl-cpp # Visualization software
              ];
            }
          )
        ];
      };

      # Audio apps
      tenacity = {pkgs, ...}: {
        key = "tenacity#homeManager";
        config = {
          # Install these apps to userspace
          home.packages = with pkgs; [
            tenacity # Audio editor
          ];
        };
      };
      musescore = {pkgs, ...}: {
        key = "musescore#homeManager";
        config = {
          # Install these apps to userspace
          home.packages = with pkgs; [
            musescore # Score editing
          ];
        };
      };
    };

    # Install foobar2000 as music player in macos; itunes doesn't play opus
    darwin.foobar = {...}: {
      key = "foobar#darwin";
      config = {
        homebrew.casks = [
          # Mask itunes
          "music-decoy"
          # Better music player for macos
          "foobar2000"
        ];
      };
    };
  };
}

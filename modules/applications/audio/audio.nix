# Music and audio related apps management
{inputs, ...}: {
  # Dispatch modules in aspect
  den = {
    aspects.collections = {
      provides.audio = {
        # Modules to load for full audio management collection
        homeManager = {...}: {
          imports = with inputs.self.modules.homeManager; [
            audio-utilities
            audio-applications
            # MIDI playback
            fluidsynth-settings
          ];
        };
      };
    };
  };

  # Audio editing tooling
  flake.modules.homeManager.audio-utilities = {
    pkgs,
    lib,
    ...
  }: {
    # Install these apps to userspace
    config = lib.mkMerge [
      {
        home.packages = with pkgs; [
          streamrip # Music downloader
          tenacity # Audio editor
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
  flake.modules.homeManager.audio-applications = {pkgs, ...}: {
    # Install these apps to userspace
    home.packages = with pkgs; [
      musescore # Score editing
    ];
  };
}

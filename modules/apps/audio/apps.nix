# Music related apps
{inputs, ...}: {
  flake.modules = {
    # Install swmpc in darwin contexts for mpd
    darwin = {
      # Install swmpc from app store
      mpd = {...}: {
        imports = [
          inputs.self.modules.darwin.mpd-gui
        ];
      };
      # Audio player from brew
      audio = {...}: {
        imports = [
          inputs.self.modules.darwin.music-applications
        ];
      };
    };

    # Apps to install
    homeManager = {
      # Audio apps
      audio = {...}: {
        imports = [
          inputs.self.modules.homeManager.audio-utilities
          inputs.self.modules.homeManager.audio-applications
          inputs.self.modules.homeManager.picard-settings
        ];
      };

      # MPD apps, cantata frontend
      mpd = {...}: {
        imports = [
          inputs.self.modules.homeManager.mpd-gui
        ];
      };
    };
  };
}

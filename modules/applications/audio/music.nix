# Music applications
{inputs, ...}: {
  # Dispatch modules in aspect
  den = {
    aspects.collections = {
      provides.music = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "collections/music(${user.userName}@${host.name})";
          # Provide darwin-only modules
          darwin = {...}: {
            imports = with inputs.self.modules.darwin; [
              # General music apps
              music-applications
              # MPD related
              mpd-gui
            ];
          };
          # Home manager collection
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              # Metadata library management
              beets-settings
              # MPD related
              mpd-settings
              mpd-ncmpcpp
              mpd-listenbrainz
              mpd-gui
            ];
          };
        };
      };
    };
  };

  # Install foobar2000 as music player in macos; itunes doesn't play opus
  flake.modules.darwin.music-applications = {...}: {
    key = "music-applications#darwin";
    config = {
      homebrew.casks = [
        # Mask itunes
        "music-decoy"
        # Better music player for macos
        "foobar2000"
      ];
    };
  };
}

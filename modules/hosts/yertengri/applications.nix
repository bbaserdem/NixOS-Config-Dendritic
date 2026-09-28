# System applications for yertengri, available on all users
{den, ...}: {
  den = {
    aspects.yertengri = {
      includes = with den.aspects; [
        # Audio
        audio
        audio._.beets
        audio._.fluidsynth
        audio._.mpd
        # Networking
        applications._.firefox
        applications._.librewolf
      ];
    };
  };
}

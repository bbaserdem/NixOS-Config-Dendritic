# Configuring terminal music player for mpd
{inputs, ...}: {
  flake.modules.homeManager.mpd = {...}: {
    imports = [
      inputs.self.modules.homeManager.mpd-ncmpcpp
    ];
  };
}

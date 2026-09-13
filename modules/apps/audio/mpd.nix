# Configuring MPD
{inputs, ...}: {
  flake.modules.homeManager.mpd = {...}: {
    imports = [
      inputs.self.modules.homeManager.mpd-settings
    ];
  };
}

# Configuring Fluidsynth
{inputs, ...}: {
  flake.modules.homeManager.midi = {...}: {
    imports = [
      inputs.self.modules.homeManager.fluidsynth-settings
    ];
  };
}

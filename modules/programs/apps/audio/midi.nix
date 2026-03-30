# Configuring Fluidsynth
{...}: {
  flake.modules.homeManager.midi = {...}: {
    # Enable fluidsynth as midi synthesizer service
    services.fluidsynth = {
      enable = true;
      soundService = "pipewire-pulse";
    };
  };
}

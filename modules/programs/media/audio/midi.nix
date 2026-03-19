# Configuring Fluidsynth
{...}: {
  flake.modules.home-manager.midi = {pkgs, ...}: {
    # Enable fluidsynth as midi synthesizer service
    services.fluidsynth = {
      enable = true;
      soundService = "pipewire-pulse";
      # Using Arachno font
      soundFont = "${pkgs.soundfont-arachno}/share/soundfonts/arachno.sf2";
    };
  };
}

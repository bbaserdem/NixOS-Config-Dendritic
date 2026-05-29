# Configuring midi playback for wolframite
{...}: {
  flake.modules.homeManager.wolframite = {pkgs, ...}: {
    services.fluidsynth.soundFont = "${pkgs.soundfont-arachno}/share/soundfonts/arachno.sf2";
  };
}

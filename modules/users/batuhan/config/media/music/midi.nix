# Configuring midi playback for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
    services.fluidsynth.soundFont = "${pkgs.soundfont-arachno}/share/soundfonts/arachno.sf2";
  };
}

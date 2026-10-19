# Fluidsynth settings
{...}: {
  flake.modules.homeManager.wolframite-fluidsynth = {
    pkgs,
    lib,
    ...
  }: {
    key = "wolframite-fluidsynth#homeManager";
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      # Soundfont for midi
      services.fluidsynth.soundFont = "${pkgs.soundfont-arachno}/share/soundfonts/arachno.sf2";
    };
  };
}

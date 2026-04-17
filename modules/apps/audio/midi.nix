# Configuring Fluidsynth
{...}: {
  flake.modules.homeManager.midi = {
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      # Enable fluidsynth as midi synthesizer service
      services.fluidsynth = {
        enable = true;
        soundService = "pipewire-pulse";
      };
    };
  };
}

# Configuring Fluidsynth
{...}: {
  flake.modules.homeManager.fluidsynth-settings = {
    lib,
    pkgs,
    ...
  }: {
    key = "fluidsynth-settings#homeManager";
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      # Enable fluidsynth as midi synthesizer service
      services.fluidsynth = {
        enable = true;
        soundService = "pipewire-pulse";
      };
    };
  };
}

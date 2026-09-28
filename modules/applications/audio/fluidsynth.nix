# Configuring Fluidsynth
{inputs, ...}: {
  den = {
    aspects.audio = {
      provides.fluidsynth = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "audio/fluidsynth(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.fluidsynth-settings
            ];
          };
        };
      };
    };
  };

  # Module
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

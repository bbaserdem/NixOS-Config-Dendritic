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
    config,
    ...
  }: {
    key = "fluidsynth-settings#homeManager";
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      services = {
        # Enable fluidsynth as midi synthesizer service
        fluidsynth = {
          enable = true;
          soundService = "pipewire-pulse";
        };
        # Tell mpd to use the decoder plugin
        mpd.extraConfig = lib.mkOrder 1100 ''
          decoder {
              plugin = "fluidsynth"
              soundfont = "${config.services.fluidsynth.soundFont or ""}"
          }
        '';
      };
    };
  };
}

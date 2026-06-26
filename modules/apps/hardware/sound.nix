# Audio settings
{...}: {
  flake.modules = {
    nixos.sound = {lib, ...}: {
      # Using PipeWire as the sound server conflicts with PulseAudio.
      # This option requires `hardware.pulseaudio.enable` to be set to false.
      services.pulseaudio.enable = false;
      # Recommended to have rtkit enabled
      security.rtkit.enable = true;
      # Main enabling script
      services.pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          # Causes openblas builds on i686-linux
          # Don't need this, unless someone else sets it
          support32Bit = lib.mkOverride 1400 false;
        };
        jack.enable = true;

        # Most this config ripped from package search, and the wiki. I don't get it
        wireplumber = {
          enable = true;
          extraConfig = {
            "log-level-debug" = {
              "context.properties" = {
                # Output Debug log messages as opposed to only the default level (Notice)
                "log.level" = "D";
              };
            };
          };
        };
      };
    };
  };
}

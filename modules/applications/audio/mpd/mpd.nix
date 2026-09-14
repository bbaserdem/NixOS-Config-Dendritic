# Configuring MPD defaults
{...}: {
  flake.modules.homeManager.mpd-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "mpd-settings#homeManager";
    config = lib.mkMerge [
      {
        # MPD configuration
        services.mpd = {
          enable = true;

          # This is lib.type.lines type, so lib.mkMerge will append lines
          extraConfig = ''
            # Library settings
            auto_update                         "yes"
            auto_update_depth                   "2"
            save_absolute_paths_in_playlists    "no"
            follow_outside_symlinks             "yes"
            follow_inside_symlinks              "no"
            # Playback settings
            restore_paused          "yes"
            metadata_to_use         "albumartist,artist,album,title,track,name,genre,date,composer,performer,disc"
            replaygain              "auto"
            volume_normalization    "no"
            # Server settings
            zeroconf_enabled        "yes"
            zeroconf_name           "MPD @ %h"
            max_connections         "50"
            max_output_buffer_size  "32786"
            # For MPD visualizer
            audio_output {
                type            "fifo"
                name            "FIFO Visualizer"
                path            "/tmp/mpd.fifo"
                format          "44100:16:2"
            }
          '';
        };

        # MPC control commands
        home.packages = with pkgs; [
          mpc
        ];
      }
      (
        # Output audio to pipewire in linux
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          services = {
            mpd.extraConfig = ''
              # Output o pulseaudio
              audio_output {
                  type            "pipewire"
                  name            "PipeWire Sound Server"
              }
            '';

            # Media playback key mapping for mpc
            mpdris2 = {
              enable = true;
              multimediaKeys = true;
              notifications = false;
            };
          };
        }
      )
      (
        # Output to CoreAudio
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          # Mpd output to coreaudio
          services.mpd.extraConfig = ''
            # Output audio to darwin
            audio_output {
                type            "osx"
                name            "CoreAudio"
                mixer_type      "software"
            }
          '';

          # Create necessary folders if they don't exist in Macos
          home.file."Library/Logs/mpd/.keep".text = "";
          xdg.dataFile."mpd/.keep".text = "";
        }
      )
    ];
  };
}

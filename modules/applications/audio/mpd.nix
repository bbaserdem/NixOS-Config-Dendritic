# Configuring MPD defaults
{
  inputs,
  lib,
  ...
}: {
  den = {
    aspects.audio = {
      provides.mpd = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "audio/mpd(${user.userName}@${host.name})";
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.mpd-gui
            ];
          };
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              mpd-settings
              mpd-ncmpcpp
              mpd-listenbrainz
              mpd-gui
            ];
            config = {
              # Assign unique port to each user
              services.mpd.network.port =
                6600
                + (
                  host.users
                  |> builtins.attrNames
                  |> lib.lists.findFirstIndex
                  (u: u == user.name)
                  (throw "Could not create user offset")
                );
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules.homeManager.mpd-settings = {
    pkgs,
    lib,
    config,
    ...
  }: {
    key = "mpd-settings#homeManager";
    config = lib.mkMerge [
      {
        # MPD configuration
        services.mpd = {
          enable = true;
          enableSessionVariables = true;
          network.listenAddress = "127.0.0.1";
          musicDirectory = config.xdg.userDirs.music or "${config.home.homeDirectory}/Music";

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
            zeroconf_name           "MPD of: ${config.home.username}@%h"
            max_connections         "50"
            max_output_buffer_size  "32786"
            # For NCMPCPP visualizer
            audio_output {
                type            "fifo"
                name            "FIFO Visualizer"
                path            "/tmp/mpd.fifo-${config.home.username}"
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
            mpd = {
              network.startWhenNeeded = true;
              extraConfig = ''
                # Output o pulseaudio
                audio_output {
                    type            "pipewire"
                    name            "PipeWire Sound Server"
                }
              '';
            };

            # Media playback key mapping for mpc
            mpdris2-rs = let
              mpdNet = config.services.mpd.network;
            in {
              enable = true;
              host = "${mpdNet.listenAddress}:${builtins.toString mpdNet.port}";
              notifications.enable = false;
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

  # GUI Apps
  flake.modules.homeManager.mpd-gui = {
    pkgs,
    lib,
    ...
  }: {
    key = "mpd-gui#homeManager";
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      home.packages = with pkgs; [
        cantata
      ];
    };
  };
  # SWMPC as gui in darwin
  flake.modules.darwin.mpd-gui = {...}: {
    key = "mpd-gui#darwin";
    config = {
      # TODO: Switch this to use programs.mas in nix-darwin 26.11
      homebrew.masApps."swmpc" = 6743818735;
      # programs.mas.packages = {
      #   swmpc = 6743818735;
      # };
    };
  };
}

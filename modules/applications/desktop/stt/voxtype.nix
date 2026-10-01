# Voxtype; local stt for linux
{inputs, ...}: {
  # Extremely badly packaged; don't trust it (still need it for cuda + osd)
  flake-file.inputs = {
    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  den = {
    aspects.desktop = {
      provides.stt = {
        # Main aspect
        provides.voxtype = {
          name = "desktop/stt/voxtype";
          provides.user-setup = {
            user,
            host,
          }: {
            name = "desktop/stt/voxtype(${user.userName}@${host.name})";
            homeManager = {
              lib,
              pkgs,
              ...
            }: {
              # Main config module; depending on what user picks
              imports = [
                inputs.self.modules.homeManager.voxtype-settings
              ];
              # Custom OSD settings
              config = lib.mkMerge [
                {
                  # TODO; establish package settings here from host metadata
                }
                (lib.mkIf user.stt.osd.enable (lib.mkMerge [
                  {
                    # Enable OSD indicator
                    services.voxtype.settings.osd.enabled = true;
                  }
                  ( # Native frontend
                    lib.mkIf (user.stt.osd.frontend == "native") {
                      services.voxtype.settings.osd = {
                        # Native frontend
                        frontend = "native";
                        width_px = 500;
                        height_px = 64;
                        position = "bottom-center";
                        waveform_gain = 10.0;
                      };
                      home.packages = [
                        inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.osd-native
                      ];
                    }
                  )
                  ( # GTK4 frontend
                    lib.mkIf (user.stt.osd.frontend == "gtk4") {
                      services.voxtype.settings.osd = {
                        # GTK4 frontend, and default settings
                        frontend = "gtk4";
                        width_px = 500;
                        height_px = 64;
                        position = "bottom-center";
                        waveform_gain = 10.0;
                      };
                      home.packages = [
                        inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.osd-gtk4
                      ];
                    }
                  )
                  ( # Quickshell frontend (needs quickshell externally)
                    lib.mkIf (user.stt.osd.frontend == "quickshell") {
                      services.voxtype.settings.osd = {
                        frontend = "quickshell";
                        position = "bottom-center";
                        style = "default";
                        layout = "orb";
                      };
                    }
                  )
                ]))
              ];
            };
          };
        };
      };
    };
  };

  flake.modules.homeManager.voxtype-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "voxtype-settings#homeManager";
    # TODO: hm module is on unstable; mainline after 26.11
    imports = [
      "${inputs.home-manager-unstable}/modules/services/voxtype.nix"
    ];
    # Module is linux only; forces systemd units
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      # Configuring the service
      services.voxtype = {
        enable = true;
        # Package needs to be done machine-based; and not in global config module

        # Global settings;
        settings = {
          # It's better to track status with state file
          state_file = "auto";

          # Hotkey should be set at desktop level; don't do evdev!
          hotkey = {
            enabled = false;
          };

          # Audio; leave defaults
          audio = {
            device = "default";
            max_duration_secs = 120;
          };

          # Output settings; needs playing around
          output = {
            mode = "type"; # Might have issues with non-qwerty layouts
            fallback_to_clipboard = true;
            paste_keys = "shift+insert";
            restore_clipboard = true;
            notification = {
              on_recording_start = true;
              on_recording_stop = true;
              on_transcription = true;
            };
            driver_order = [
              "wtype"
              "dotool"
              "ydotool"
              "clipboard"
            ];
          };

          # Text settings
          text = {
            spoken_punctuation = true;
          };

          # Visualization settings
          osd = {
            # Don't install the backend by default; it takes time to compile
            enabled = lib.mkDefault false;
          };

          # Status bar indicator
          status = {
            icon_theme = "nerd-font";
          };
        };
      };
    };
  };
}

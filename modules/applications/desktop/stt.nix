# Speech to text solutions
{inputs, ...}: {
  # Extremely badly packaged; don't trust it; (unless we want the cuda packages)
  # flake-file.inputs = {
  #   voxtype = {
  #     url = "github:peteonrails/voxtype";
  #     inputs.nixpkgs.follows = "nixpkgs-unstable";
  #   };
  # };
  den = {
    aspects.desktop = {
      provides.voxtype = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/voxtype(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.voxtype-settings
            ];
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
    config = lib.mkMerge [
      ( # Module is linux only; forces systemd units
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # Configuring the service
          services.voxtype = {
            enable = true;

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
                enabled = true;
                frontend = "native";
                # For quickshell OSD
                style = "default";
                # palette = TODO: stylix this
                layout = "orb";
                # For native/gtk
                width_px = 500;
                height_px = 64;
                position = "bottom-center";
                top_margin = 0.85;
                opacity = 0.9;
                waveform_gain = 10.0;
              };

              # Status bar indicator
              status = {
                icon_theme = "nerd-font";
              };
            };
          };

          # OSD provider package
          # home.packages = with pkgs; [
          # voxtype-upstream.osd-native
          # ];
        }
      )
    ];
  };
}

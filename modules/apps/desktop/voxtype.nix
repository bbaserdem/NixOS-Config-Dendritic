# Voxtype; STT solution
{inputs, ...}: {
  # We pull the upstream flake for the home-manager module mostly
  # TODO: Module in home-manager unstable; switch to that once done
  flake-file.inputs = {
    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  flake.modules = {
    nixos.voxtype = {
      pkgs,
      lib,
      ...
    }: {
      # Configure voxtype per system
      imports = [
        inputs.voxtype.nixosModules.default
      ];

      config = {
        programs = {
          # Voxtype, default package
          voxtype = {
            enable = true;
            package = lib.mkOverride 1400 pkgs.voxtype;
          };
          # Need ydotool for copy/paste
          ydotool.enable = lib.mkDefault true;
        };
      };
    };

    darwin.voxtype = {...}: {
      # Install from custom homebrew tap
      homebrew = {
        taps = ["peteonrails/voxtype"];
        brews = ["voxtype"];
      };
    };

    homeManager.voxtype = {
      pkgs,
      lib,
      ...
    } @ args: {
      # Configure voxtype
      imports = [
        inputs.voxtype.homeManagerModules.default
      ];

      config = lib.mkMerge [
        (
          # Module is linux only for now
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (
            lib.mkMerge [
              (
                # Pull from nixos config if we are nixos module
                lib.optionalAttrs (lib.hasAttrByPath ["osConfig"] args) {
                  programs.voxtype.package = args.osConfig.programs.voxtype.package;
                }
              )
              (
                # Default to regular if we are not
                lib.optionalAttrs (!(lib.hasAttrByPath ["osConfig"] args)) {
                  programs.voxtype.package = pkgs.voxtype;
                }
              )
              {
                # Configuring the service
                programs.voxtype = {
                  enable = true;

                  # Enable the systemd service
                  service.enable = true;

                  # Global settings;
                  settings = {
                    # Hotkey should be set at desktop level; don't do evdev
                    hotkey.enabled = false;
                    # It's better to track status with state file
                    state_file = "auto";

                    # Output settings
                    output = {
                      mode = "paste";
                      paste_keys = "shift+insert";
                      restore_clipboard = true;
                      fallback_to_clipboard = true;
                      notification = {
                        on_recording_start = false;
                        on_recording_stop = false;
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
                      layout = "compact";
                      # For native/gtk
                      width_px = 500;
                      height_px = 64;
                      position = "bottom-center";
                      top_margin = 0.85;
                      opacity = 0.9;
                      waveform_gain = 10.0;
                    };
                  };
                };

                home.packages = [
                  inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.osd-native
                  # inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.osd-gtk4
                ];
              }
            ]
          )
        )
      ];
    };
  };
}

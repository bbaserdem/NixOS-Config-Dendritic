# Voxtype; local stt for linux
{
  inputs,
  den,
  lib,
  ...
}: {
  # Extremely badly packaged; don't trust it (still need it for cuda + osd)
  flake-file.inputs = {
    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  den = {
    schema = {
      host.options = {
        desktop = lib.mkOption {
          type = lib.types.submodule {
            options = {
              stt = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    voxtype = lib.mkOption {
                      description = "Voxtype metadata used by this host";
                      default = {};
                      type = lib.types.submodule {
                        options = {
                          enable = lib.mkOption {
                            description = "Enable voxtype on this host";
                            default = false;
                            type = lib.types.bool;
                          };
                          backend = lib.mkOption {
                            description = "Backend to use for transcription";
                            default = null;
                            type = lib.types.nullOr (lib.types.enum [
                              "parakeet-cuda"
                              "whisper-vulkan"
                            ]);
                          };
                          # TODO: formalize the frontend
                          frontend = lib.mkOption {
                            description = "On-screen display to use";
                            default = null;
                            type = lib.types.nullOr (lib.types.enum [
                              "native"
                              "gtk4"
                              "quickshell"
                            ]);
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
      user.includes = [
        den.aspects.desktop._.stt._.voxtype.policies.voxtype-user-dispatch
      ];
    };

    aspects.desktop = {
      provides.stt = {
        # Main aspect
        provides.voxtype = {
          name = "desktop/stt/voxtype";
          # Dispatch policy
          policies.voxtype-user-dispatch = {
            host,
            user,
            ...
          }:
            lib.optionals
            (host.desktop.stt.enable && user.stt.enable && host.desktop.stt.voxtype.enable)
            (
              [
                (
                  den.lib.policy.include
                  den.aspects.desktop._.stt._.voxtype._.user-setup
                )
              ]
              ++ (
                lib.optional
                (host.desktop.stt.voxtype.backend != null)
                (
                  den.lib.policy.include
                  den.aspects.desktop._.stt._.voxtype._.${host.desktop.stt.voxtype.backend}
                )
              )
            );

          provides = {
            # Variant; parakeet models, with cuda suport
            parakeet-cuda = {
              user,
              host,
            }: {
              name = "desktop/stt/voxtype/parakeet-cuda(${user.userName}@${host.name})";
              homeManager = {...}: {
                imports = [
                  inputs.self.modules.homeManager.voxtype-parakeet-cuda
                ];
              };
            };
            # Variant; whisper with additional turkish transcription
            whisper-vulkan = {
              user,
              host,
            }: {
              name = "desktop/stt/voxtype/whisper-vulkan(${user.userName}@${host.name})";
              homeManager = {...}: {
                imports = [
                  inputs.self.modules.homeManager.voxtype-whisper-vulkan
                ];
              };
            };

            # Generic user setup
            user-setup = {
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
  };

  flake.modules.homeManager = {
    # Mode specific
    voxtype-parakeet-cuda = {pkgs, ...}: {
      key = "voxtype-parakeet-cuda#homeManager";
      config = {
        services.voxtype = {
          # The model to load
          loadModels = [];
          # Settings for this mode
          settings = {
            engine = "parakeet";
            hotkey.mode = "toggle";
            parakeet = {
              model = "${pkgs.local.parakeet-unified-en-06b}/share/parakeet/parakeet-unified-en-0.6b";
              streaming = true;
              # Keep model loaded TODO: test if this causes issues
              on_demand_loading = false;
              # Invalid defaults; needs to be multiple of .08 seconds
              streaming_chunk_secs = 0.56;
              streaming_left_context_secs = 5.6;
              streaming_right_context_secs = 0.56;
            };
          };
          # The voxtype package; build for cuda support
          package =
            (
              pkgs.voxtype-onnx.override
              {
                # This override is redundant on nixpkgs.config.cudaSupport = true
                onnxruntime = pkgs.onnxruntime.override {cudaSupport = true;};
              }
            ).overrideAttrs (old: {
              # Need these build features added to bake in cuda support
              buildFeatures = [
                "parakeet-load-dynamic"
                "parakeet-cuda"
              ];
              # Add cuda to build deps
              nativeBuildInputs =
                (old.nativeBuildInputs or [])
                ++ (with pkgs.cudaPackages; [
                  cuda_nvcc
                ]);
              buildInputs =
                (old.buildInputs or [])
                ++ (with pkgs.cudaPackages; [
                  cudatoolkit
                  cudnn
                ]);
            });
          # TODO: Check; the package might need cuda libraries provided to it
          # environment = {
          #   LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs.cudaPackages; [
          #     "/run/opengl-driver"
          #     cudatoolkit
          #     cudnn
          #   ]);
          # };
        };
      };
    };
    voxtype-whisper-vulkan = {pkgs, ...}: {
      key = "voxtype-whisper#homeManager";
      config = {
        services.voxtype = {
          # The model to load
          loadModels = [];
          # Settings for this mode
          settings = {
            engine = "whisper";
            hotkey.mode = "toggle";
            whisper = {
              mode = "local";
              model = "${pkgs.local.whisper-model-large-v3-turbo}/share/whisper/ggml-large-v3-turbo.bin";
              language = ["en" "tr"];
              translate = false;
              on_demand_loading = false;
              streaming = true;
            };
            streaming = {
              interval_secs = 0.8;
              max_buffer_secs = 29.0;
              min_speech_rms = 0.005;
              min_audio_secs = 1.0;
              partial_min_words = 1;
              type_partials = true;
              revision_mode = false;
            };
          };
          # The voxtype package; needs 1.1.0 which is in unstable
          package = pkgs.unstable.voxtype-vulkan;
        };
      };
    };

    # Global
    voxtype-settings = {
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
  };
}

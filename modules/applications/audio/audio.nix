# Audio tools; base aspect
{
  inputs,
  den,
  lib,
  ...
}: {
  # Dispatch modules in aspect
  den = {
    # Feature schema
    schema.host = {
      includes = [
        den.aspects.audio.policies.airplay-host-dispatch
      ];
      options = {
        audio = lib.mkOption {
          type = lib.types.submodule {
            options = {
              airplay = lib.mkOption {
                description = "Whether to enable airplay on this host.";
                default = true;
                type = lib.types.bool;
              };
            };
          };
        };
      };
    };

    aspects.audio = {
      # Base aspect
      name = "audio";

      # Policy for airplay
      policies.airplay-host-dispatch = {host, ...}:
        lib.optional
        (
          (host.class == "nixos")
          && host.audio.enable
          && host.audio.airplay
          && host.networking.zeroconf.enable
        )
        (den.lib.policy.include den.aspects.audio._.airplay);
      provides.airplay = {
        name = "audio/airplay";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.audio-airplay
          ];
        };
        # Open local discovery ports
        local-ports = {
          from = 6001;
          to = 6002;
          proto = "udp";
        };
      };

      # Global dispatch
      provides.to-users = {
        host,
        user,
      }: {
        name = "audio(${user.userName}@${host.name})";
        # Modules to load for full audio management collection
        homeManager = {...}: {
          imports = with inputs.self.modules.homeManager; [
            audio-utilities
          ];
        };
      };

      # Applications
      provides.tenacity = {
        name = "audio/tenacity";
        provides.to-users = {
          host,
          user,
        }: {
          name = "audio/tenacity(${user.userName}@${host.name})";
          # Modules to load for full audio management collection
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.tenacity
            ];
          };
        };
      };
      provides.musescore = {
        name = "audio/musescore";
        provides.to-users = {
          host,
          user,
        }: {
          name = "audio/musescore(${user.userName}@${host.name})";
          # Modules to load for full audio management collection
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.musescore
            ];
          };
        };
      };
      provides.foobar = {
        name = "audio/foobar";
        provides.to-users = {
          host,
          user,
        }: {
          name = "audio/foobar(${user.userName}@${host.name})";
          # Modules to load for full audio management collection
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.foobar
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    homeManager = {
      # Utilities to help with music files
      audio-utilities = {
        pkgs,
        lib,
        ...
      }: {
        key = "audio-utilities#homeManager";
        # Install these apps to userspace
        config = lib.mkMerge [
          {
            home.packages = with pkgs; [
              streamrip # Music downloader
              whipper # CD ripping utility
              chromaprint # Calculate acoustic id
              local.audman # Personal transcoding script
            ];
          }
          (
            # Broken on darwin, install to linux only
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              home.packages = with pkgs; [
                projectm-sdl-cpp # Visualization software
              ];
            }
          )
        ];
      };

      # Audio apps
      tenacity = {pkgs, ...}: {
        key = "tenacity#homeManager";
        config = {
          # Install these apps to userspace
          home.packages = with pkgs; [
            tenacity # Audio editor
          ];
        };
      };
      musescore = {pkgs, ...}: {
        key = "musescore#homeManager";
        config = {
          # Install these apps to userspace
          home.packages = with pkgs; [
            musescore # Score editing
          ];
        };
      };
    };

    # Install foobar2000 as music player in macos; itunes doesn't play opus
    darwin.foobar = {...}: {
      key = "foobar#darwin";
      config = {
        homebrew.casks = [
          # Mask itunes
          "music-decoy"
          # Better music player for macos
          "foobar2000"
        ];
      };
    };

    # Nixos config module to enable airplay
    nixos.audio-airplay = {...}: {
      key = "audio-airplay#nixos";
      config = {
        # Set up pipewire for airplay streaming
        services.pipewire.extraConfig.pipewire = {
          "10-airplay" = {
            "context.modules" = [
              {
                name = "libpipewire-module-raop-discover";

                # increase the buffer size if you get dropouts/glitches
                # args = {
                #   "raop.latency.ms" = 500;
                # };
              }
            ];
          };
        };
      };
    };
  };
}

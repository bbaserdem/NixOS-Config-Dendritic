# Audio output in nixos
{
  lib,
  den,
  inputs,
  ...
}: {
  den = {
    # Audio toggle to host schema
    schema.host = {config, ...}: {
      options = {
        audio = lib.mkOption {
          description = "Audio features for this host (NixOS only)";
          default =
            if config.class == "nixos"
            then {}
            else null;
          apply = value:
            if config.class == "nixos"
            then value
            else if (value != null)
            then
              throw ''
                Host ${config.name}'s audio option must be null if not "nixos"
                ${config.name}.class is currently `${config.class}`
              ''
            else null;
          type = lib.types.nullOr (
            lib.types.submodule ({...}: {
              options = {
                enable = lib.mkOption {
                  description = "Whether to enable audio on this host";
                  default = true;
                  type = lib.types.bool;
                };
                airplay = lib.mkOption {
                  description = "Whether to enable airplay integration.";
                  default = true;
                  type = lib.types.bool;
                };
              };
            })
          );
        };
      };
    };

    aspects.system = {
      provides.nixos = {
        # Policy to enable audio module on nixos
        includes = [
          den.aspects.system._.nixos.policies.nixos-audio-dispatch
        ];
        policies.nixos-audio-dispatch = {host, ...}:
          lib.optionals
          (
            (host.audio != null)
            && (host.audio.enable or false)
          ) (
            [
              (den.lib.policy.include den.aspects.system._.nixos._.audio)
            ]
            ++ (
              lib.optional
              (host.audio.airplay or false)
              (den.lib.policy.include den.aspects.system._.nixos._.audio._.airplay)
            )
          );

        # Full audio aspect
        provides.audio = {
          name = "system/nixos/audio";
          # Provides pipewire
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-pipewire
            ];
          };
          # Provide airplay integration to pipewire
          provides.airplay = {
            name = "system/nixos/audio/airplay";
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.nixos-pipewire-airplay
              ];
            };
            # Open local discovery ports
            local-ports = {
              from = 6001;
              to = 6002;
              proto = "udp";
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.nixos = {
    nixos-pipewire = {...}: {
      key = "nixos-pipewire#nixos";
      config = {
        # Recommended to have rtkit enabled
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          # Set as main sound server
          audio.enable = true;
          # Enable backends
          pulse.enable = true;
          alsa = {
            enable = true;
            support32Bit = true; # Might need disabling in i864; openblas rebuild?
          };
          jack.enable = true;
          wireplumber.enable = true;
        };
      };
    };
    nixos-pipewire-airplay = {...}: {
      key = "nixos-pipewire-airplay#nixos";
      config = {
        # Sets up pipewire; but needs avahi configured for this
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

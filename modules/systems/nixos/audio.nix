# Audio output in nixos
{
  lib,
  den,
  inputs,
  ...
}: {
  den = {
    # Audio toggle to host schema
    schema.host = {
      imports = [
        ({config, ...}: {
          options = {
            audio = lib.mkOption {
              description = "Audio features for this host.";
              default = {};
              type = lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    description = "Whether to enable audio on this host";
                    default = config.class == "nixos";
                    type = lib.types.bool;
                  };
                };
              };
            };
          };
        })
      ];
    };

    aspects.system = {
      provides.nixos = {
        # Policy to enable audio module on nixos
        includes = [
          den.aspects.system._.nixos.policies.audio-dispatch
        ];
        policies.audio-dispatch = {host, ...}:
          lib.optional
          host.audio.enable
          (den.lib.policy.include den.aspects.system._.nixos._.audio);

        # Full audio aspect
        provides.audio = {
          name = "system/nixos/audio";
          # Provides pipewire
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-pipewire
            ];
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
  };
}

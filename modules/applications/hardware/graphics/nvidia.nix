# Nvidia graphics drivers
{
  den,
  lib,
  inputs,
  ...
}: {
  den = {
    # Host schema to subscribe to certain graphics modules
    schema.host = {
      includes = [
        den.aspects.hardware._.graphics.policies.nvidia-host-dispatch
      ];
      options = {
        hardware = lib.mkOption {
          type = lib.types.submodule {
            options = {
              graphics = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    nvidia = lib.mkOption {
                      description = "Nvidia related settings";
                      default = {};
                      type = lib.types.submodule {
                        options = {
                          enable = lib.mkOption {
                            description = "Enable the nvidia driver.";
                            default = false;
                            type = lib.types.bool;
                          };
                          open = lib.mkOption {
                            description = "Whether to use the open source driver";
                            default = true;
                            type = lib.types.bool;
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
    };

    aspects.hardware = {
      provides.graphics = {
        # Policy for dispatch
        policies.nvidia-host-dispatch = {host, ...}:
          lib.optional
          (
            (host.class == "nixos")
            && host.hardware.graphics.enable
            && host.hardware.graphics.nvidia.enable
          )
          (den.lib.policy.include den.aspects.hardware._.graphics._.nvidia);

        # Aspect
        provides.nvidia = {host}: {
          name = "hardware/graphics/nvidia(@${host.name})";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.graphics-nvidia
            ];
            config = {
              hardware = {
                nvidia = {
                  inherit (host.hardware.graphics.nvidia) open;
                };
                # Enable the toolkit for GPU access from containers
                nvidia-container-toolkit =
                  lib.mkIf
                  host.development.containerization.enable
                  {enable = true;};
              };
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules.nixos = {
    graphics-nvidia = {...}: {
      key = "graphics-nvidia#nixos";
      config = {
        # Add to kernel modules
        services.xserver.videoDrivers = ["nvidia"];
        # Driver
        hardware.nvidia = {
          modesetting.enable = true;
        };
      };
    };
  };
}

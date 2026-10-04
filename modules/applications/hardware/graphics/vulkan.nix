# Vulkan graphics drivers
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
        den.aspects.hardware._.graphics.policies.vulkan-host-dispatch
      ];
      options = {
        hardware = lib.mkOption {
          type = lib.types.submodule {
            options = {
              graphics = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    vulkan = lib.mkOption {
                      description = "Vulkan related settings";
                      default = {};
                      type = lib.types.submodule {
                        options = {
                          enable = lib.mkOption {
                            description = "Enable vulkan on this host.";
                            default = false;
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
        policies.vulkan-host-dispatch = {host, ...}:
          lib.optional
          (
            (host.class == "nixos")
            && host.hardware.graphics.enable
            && host.hardware.graphics.vulkan.enable
          )
          (den.lib.policy.include den.aspects.hardware._.graphics._.vulkan);

        # Aspect
        provides.vulkan = {
          name = "hardware/graphics/vulkan";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.graphics-vulkan
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.nixos.graphics-vulkan = {pkgs, ...}: {
    key = "graphics-vulkan#nixos";
    config = {
      # User tooling
      environment.systemPackages = with pkgs; [
        vulkan-tools
      ];
    };
  };
}

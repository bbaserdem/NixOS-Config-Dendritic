# Nixos; graphics tooling
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Host schema to subscribe to certain graphics modules
    schema.host = {
      options = {
        graphics = lib.mkOption {
          description = "Graphics related settings. (NixOS)";
          default = {};
          type = lib.types.submodule {
            options = {
              modules = lib.mkOption {
                description = "Shared modules to load.";
                type = lib.types.listOf (lib.types.enum [
                  "vulkan"
                ]);
                default = [];
              };
            };
          };
        };
      };
    };

    # Aspect
    aspects.system = {
      provides.nixos = {
        # Policy to dispatch requested graphical modules
        includes = [
          den.aspects.system._.nixos._.graphics
        ];
        provides.graphics = {
          name = "system/nixos/graphics";
          # Policy to dispatch requested graphical modules
          includes = [
            den.aspects.system._.nixos._.graphics.policies.nixos-graphics-dispatch
          ];
          policies.nixos-graphics-dispatch = {host, ...}:
            lib.optionals
            (host.graphics.modules != [])
            (
              host.graphics.modules
              |> builtins.map (
                n: (den.lib.policy.include den.aspects.system._.nixos._.graphics._.${n})
              )
            );
          # Vulkan aspect
          provides.vulkan = {
            name = "sytem/nixos/graphics/vulkan";
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.nixos-vulkan
              ];
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules.nixos = {
    nixos-vulkan = {pkgs, ...}: {
      key = "nixos-vulkan#nixos";
      config = {
        # User tooling
        environment.systemPackages = with pkgs; [
          vulkan-tools
        ];
      };
    };
  };
}

# Configuring OS defaults for nixos
{
  inputs,
  den,
  config,
  ...
}: {
  den.aspects = {
    # Base configuration for all NixOS systems
    system = {
      provides.nixos = {
        name = "system/nixos";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.nixos-defaults
          ];
        };
        # Info aspect; parametric
        includes = [
          den.aspects.system._.nixos._.system-info
        ];
        provides.system-info = {host}: {
          name = "system/nixos/system-info(@${host.name})";
          nixos = {lib, ...}: {
            # Full computer name
            config = lib.mkIf (host.description != null) {
              hardware.bluetooth.settings.General.Name = host.description;
            };
          };
        };
      };
    };
  };

  flake.modules.nixos.nixos-defaults = {
    lib,
    options,
    ...
  }: {
    key = "nixos-defaults#nixos";
    config = lib.mkMerge [
      {
        # Our default state version for our nixos systems
        system.stateVersion = lib.mkOverride 110 config.nixpkgs.version;
      }
      ( # Establish the defaults for managed home-manager invocations
        lib.mkIf (options ? home-manager) {
          home-manager.sharedModules = [
            inputs.self.modules.homeManager.hm-defaults
          ];
        }
      )
    ];
  };
}

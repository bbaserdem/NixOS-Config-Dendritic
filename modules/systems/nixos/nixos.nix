# Configuring OS defaults for nixos
{
  inputs,
  den,
  ...
}: {
  den.aspects = {
    # Base configuration for all NixOS systems
    system = {
      provides.nixos = {
        name = "system/nixos";
        includes = [
          den.aspects.system._.nixos._.system-info
        ];
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.nixos-defaults
          ];
        };
        # Info aspect
        provides.system-info = {host}: {
          name = "system/nixos/system-info(@${host.name})";
          nixos = {lib, ...}: {
            config = lib.mkMerge [
              ( # Full computer name
                lib.mkIf (host.description != null) {
                  hardware.bluetooth.settings.General.Name = host.description;
                }
              )
              ( # State version
                lib.mkIf (host.stateVersion != null) {
                  system.stateVersion = host.stateVersion;
                }
              )
            ];
          };
        };
      };
    };
  };

  flake.modules.nixos.nixos-defaults = {lib, ...}: {
    key = "nixos-defaults#nixos";
    config = {
      # Our default state version for our nixos systems
      # TODO: default this to flake version
      system.stateVersion = lib.mkDefault "26.05";
    };
  };
}

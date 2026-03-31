# Host related flake-parts configuration
{
  inputs,
  lib,
  flake-parts-lib,
  ...
}: {
  # currently, there's no nix-darwin module for flake-parts,
  # Manually add flake.darwinConfigurations as flake output
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      darwinConfigurations = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
      };
    };
  };

  config = {
    flake = {
      # Host related functionality creating system / home-manager configurations

      modules = {
        # Default settings modules

        # NixOS
        nixos.default = {...}: {
          system.stateVersion = "25.11";
        };

        # Darwin
        darwin.default = {...}: {
          system.stateVersion = "6";
        };
      };

      lib = {
        # System builders

        # Nixos system builder, allows customizing the output name parameter
        mkNixos = {
          system,
          name,
          ...
        }: {
          ${name} = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              inputs.self.modules.generic.nixpkgs
              inputs.self.modules.nixos.default
              inputs.self.modules.nixos.${name}
              {
                nixpkgs.hostPlatform = lib.mkDefault system;
                networking.hostName = "${name}";
                # hardware.bluetooth.settings.General.Name
              }
            ];
          };
        };

        # Nix-Darwin config builder
        mkDarwin = {
          system,
          name,
          ...
        }: {
          ${name} = inputs.nix-darwin.lib.darwinSystem {
            modules = [
              inputs.self.modules.generic.nixpkgs
              inputs.self.modules.darwin.default
              inputs.self.modules.darwin.${name}
              ({config, ...}: {
                nixpkgs.hostPlatform = lib.mkDefault system;
                networking = {
                  hostName = "${name}";
                  localHostName = "${config.networking.hostName}.local";
                  # computerName
                };
              })
            ];
          };
        };
      };
    };
  };
}

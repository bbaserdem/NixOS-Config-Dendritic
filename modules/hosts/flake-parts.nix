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
        # Host specific setting definitions to propagate inside system
        generic.hostConstants = {lib, ...}: {
          options = {
            hostname = lib.mkOption {
              type = lib.types.nullOr lib.types.string;
              description = "Hostname for this system";
              default = null;
            };
          };
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
              inputs.self.modules.generic.hostConstants
              {hostConstants.hostname = name;}
              inputs.self.modules.generic.nixpkgs
              inputs.self.modules.nixos.${name}
              {nixpkgs.hostPlatform = lib.mkDefault system;}
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
              inputs.self.modules.generic.hostConstants
              {hostConstants.hostname = name;}
              inputs.self.modules.generic.nixpkgs
              inputs.self.modules.darwin.${name}
              {nixpkgs.hostPlatform = lib.mkDefault system;}
            ];
          };
        };
      };
    };
  };
}

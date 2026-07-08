{
  inputs,
  lib,
  config,
  den,
  ...
}: {
  # Declarative disk partitioning for NixOS
  # https://github.com/nix-community/disk

  imports = [
    (inputs.disko.flakeModules.default or {})
  ];

  config = let
    devicesNameSpace = "disks";
  in {
    # Import disko flake-parts module into our flake
    flake-file.inputs.disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    den = {
      # Define disk output for den host-kind entities.
      schema.host = {
        options = {
          "${devicesNameSpace}" = lib.mkOption {
            type = lib.types.nullOr (lib.types.lazyAttrsOf lib.types.raw);
            default = null;
            description = ''
              `devices` attrset for disko.
              Setting it enables disko management.
            '';
          };
        };

        includes = [den.aspects.disko];
      };

      # Define disko aspect for den host-kind entities
      aspects.disko = {host}: {
        nixos = {...}: (lib.optionalAttrs (host."${devicesNameSpace}" != null) {
          imports = [
            inputs.disko.nixosModules.disko
          ];
          config = {
            disko.devices = host."${devicesNameSpace}";
          };
        });
      };
    };

    # Disko configurations output from den hosts
    flake.diskoConfigurations =
      config.den.hosts
      |> lib.concatMapAttrs (
        _system: hosts:
          hosts
          |> lib.filterAttrs (_: host: host.disks != null)
          |> lib.mapAttrs (_name: host: {disko.devices = host."${devicesNameSpace}";})
      );
  };
}

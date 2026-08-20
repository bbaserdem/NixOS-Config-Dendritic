{
  inputs,
  lib,
  config,
  den,
  ...
}: let
  devicesNameSpace = "disks";
in {
  # Declarative disk partitioning for NixOS
  # https://github.com/nix-community/disk

  # Import flake-parts module
  imports = [
    (inputs.disko.flakeModules.default or {})
  ];

  config = {
    # Import disko input into our flake
    flake-file.inputs.disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wire den so that there is an option for hosts to define their disco config
    # And it's wired to the outputs
    den = {
      # Define disk output for den host entities
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

        # Policy; include the aspect when the host is of nixos type
        includes = [
          den.policies.disko
        ];
      };

      # Define the disko aspect for den host-kind entities
      aspects.disko = {host}: {
        nixos = {...}: {
          imports = [
            inputs.disko.nixosModules.disko
          ];
          # We condition on disko definition existing before dispatch;
          config = lib.optionalAttrs (host."${devicesNameSpace}" != null) {
            disko.devices = host."${devicesNameSpace}";
          };
        };
      };

      # Policy; disko aspect should be included if a host is of nixos type
      policies.disko = {host, ...}:
        lib.optional (
          (host.class == "nixos")
          && (host."${devicesNameSpace}" != null)
        ) [
          (den.lib.policy.include den.aspects.disko)
        ];
    };

    # Disko configurations output, pulled from den host-kind entities' record
    flake.diskoConfigurations =
      config.den.hosts
      |> lib.concatMapAttrs (
        _system: hosts:
          hosts
          |> lib.filterAttrs (_: host: host.class == "nixos")
          |> lib.filterAttrs (_: host: host.disks != null)
          |> lib.mapAttrs (_name: host: {disko.devices = host."${devicesNameSpace}";})
      );
  };
}

{
  inputs,
  lib,
  config,
  den,
  ...
}: let
  # Central location for option name; can change this in the future if needed
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
      # Define disk output attrset for den host entities
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
          den.aspects.disko.policies.disko-host-dispatch
        ];
      };

      # Define the disko aspect for den host-kind entities
      aspects.disko = {
        name = "disko";
        # Dispatch policy
        includes = [
          den.aspects.disko._.host-setup
        ];
        policies.disko-host-dispatch = {host, ...}:
          lib.optional
          ((host.class == "nixos") && (host."${devicesNameSpace}" != null))
          (den.lib.policy.include den.aspects.disko);
        # Main aspect
        provides.host-setup = {host}: {
          name = "disko(@${host.name})";
          nixos = {...}: {
            imports = [
              inputs.disko.nixosModules.disko
            ];
            config = {
              disko.devices = host."${devicesNameSpace}";
            };
          };
        };
      };
    };

    # Disko configurations output, pulled from den host-kind entities' record
    flake.diskoConfigurations =
      config.den.hosts
      |> lib.concatMapAttrs (
        _system: hosts:
          hosts
          |> lib.filterAttrs (
            _: host: (
              (host.class == "nixos")
              && (host.${devicesNameSpace} != null)
            )
          )
          |> lib.mapAttrs (_name: host: {disko.devices = host."${devicesNameSpace}";})
      );
  };
}

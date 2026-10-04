# Home-Manager system context modules
{
  inputs,
  config,
  den,
  lib,
  ...
}: {
  # Load the home-manager flake-parts module
  imports = [
    (inputs.home-manager.flakeModules.home-manager or {})
  ];

  config = {
    # Home-manoger flake source
    flake-file.inputs = {
      home-manager = {
        url = "github:nix-community/home-manager/release-${config.nixpkgs.version}";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      home-manager-unstable = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    den = {
      # Include the HM host configuration aspect when needed
      schema.host.includes = [den.aspects.home-manager.policies.hm-host-dispatch];

      # Base aspect configuring home-manager
      aspects.home-manager = {
        name = "home-manager";
        policies = {
          hm-host-dispatch = {host, ...}:
            lib.optional
            (
              (host.class == "homeManager") # If we are standalone hm
              || ( # If we are an os with hm managed users
                host.users
                |> builtins.attrValues
                |> builtins.any (u: builtins.elem "homeManager" u.classes)
              )
            )
            (den.lib.policy.include den.aspects.home-manager);
        };
        # Built-in battery routes proper modules to nixos/darwin hosts, but repeat
        os = {...}: {
          imports = [
            inputs.self.modules.generic.hm-os-settings
          ];
        };
        nixos = {...}: {
          imports = [
            inputs.home-manager.nixosModules.home-manager
          ];
        };
        darwin = {...}: {
          imports = [
            inputs.home-manager.darwinModules.home-manager
          ];
        };
      };
    };

    # Modules
    flake.modules.generic.hm-os-settings = {
      lib,
      options,
      ...
    }: {
      key = "hm-os-settings#generic";
      config = lib.optionalAttrs (options ? home-manager) {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          overwriteBackup = true;
        };
      };
    };
  };
}

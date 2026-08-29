{
  inputs,
  config,
  lib,
  den,
  ...
}: let
  version = config.localConfig.nixVersion;
in {
  config = {
    # Stylix is system-wide theming tool
    flake-file.inputs = {
      stylix.url = "github:nix-community/stylix/release-${version}";
      base16.url = "github:SenchoPens/base16.nix";
      tinted-terminal = {
        url = "github:tinted-theming/tinted-terminal";
        flake = false;
      };
    };

    den = {
      # Forward battery for custom stylix class
      classes = {
        stylix.description = ''
          Stylix configuration forwarded into appropriate setting;
          - from host scopes; delivers to the host's class
          - from host, user scopes; delivers to the (same scope's) homeManager class
        '';
        stylixOs.description = ''
          Stylix configuration forwarded into the host OS;
          - from host, user scopes; delivers to the host's class
        '';
      };

      policies = {
        # Deliver stylix class to host scope's targets
        stylix-to-host-scope = {host, ...}:
          lib.optional (
            builtins.elem host.class ["nixos" "darwin" "homeManager"]
          )
          (den.lib.policy.route {
            fromClass = "stylix";
            intoClass = host.class;
            intoPath = ["stylix"];
            guard = {options, ...}: options ? stylix;
          });

        # Deliver stylix class to user's homeManager, or host targets
        stylix-to-user-scope = {
          host,
          user,
          ...
        }:
          [
            (den.lib.policy.route {
              fromClass = "stylix";
              intoClass = "homeManager";
              intoPath = ["stylix"];
              guard = {options, ...}: options ? stylix;
            })
          ]
          ++ (
            lib.optional
            (builtins.elem host.class ["nixos" "darwin"])
            (den.lib.policy.route {
              fromClass = "stylixOs";
              intoClass = host.class;
              intoPath = ["stylix"];
              guard = {options, ...}: options ? stylix;
            })
          );
      };

      schema = {
        host.includes = [den.policies.stylix-to-host-scope];
        user.includes = [den.policies.stylix-to-user-scope];
      };

      # The setup of the feature
      aspects.stylix = {
        os = {...}: {
          stylix = {
            enable = true;
            autoEnable = false;
          };
        };
        # Module loading, home-manager should only get enabled in standalone
        nixos = {...}: {
          imports = [inputs.stylix.nixosModules.stylix];
        };
        darwin = {...}: {
          imports = [inputs.stylix.darwinModules.stylix];
        };
        homeManager = {...}: {
          imports = [inputs.stylix.homeModules.stylix];
          config = {
            stylix = {
              enable = true;
              autoEnable = false;
            };
          };
        };
      };
    };

    # TODO: Retire after full den migration
    # Flake modules that enables stylix
    flake.modules = {
      # Generic behavior settings for all contexts
      generic.stylix = {...}: {
        stylix = {
          enable = true;
          autoEnable = false;
        };
      };

      # Context-specific module loading
      nixos.stylix = {...}: {
        imports = [
          inputs.stylix.nixosModules.stylix
        ];
      };
      darwin.stylix = {...}: {
        imports = [
          inputs.stylix.darwinModules.stylix
        ];
      };

      # In standalone hm context, this module needs to be loaded
      # We do the enables here too
      homeManager.stylix-hms = {...}: {
        imports = [
          inputs.stylix.homeModules.stylix
          inputs.self.modules.homeManager.stylix
        ];
      };
    };
  };
}

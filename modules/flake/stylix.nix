{
  inputs,
  config,
  lib,
  den,
  ...
}: {
  config = {
    # Stylix is system-wide theming tool
    flake-file.inputs = {
      stylix.url = "github:nix-community/stylix/release-${config.nixpkgs.version}";
      # External tooling used to generate for stylix overrides
      base16.url = "github:SenchoPens/base16.nix";
      tinted-terminal = {
        url = "github:tinted-theming/tinted-terminal";
        flake = false;
      };
    };

    den = {
      # Forward battery for custom stylix class
      classes.stylix.description = ''
        Stylix configuration forwarded into appropriate setting;
        - from host scopes; delivers to the host's class
        - from host, user scopes; delivers to the (same scope's) homeManager class
      '';

      policies = {
        # Deliver stylix class to host scope's targets
        stylix-to-host-scope = {host, ...}:
          lib.optionals
          (builtins.elem host.class ["nixos" "darwin" "homeManager"])
          [
            (den.lib.policy.route {
              fromClass = "stylix";
              intoClass = host.class;
              intoPath = ["stylix"];
              guard = {options, ...}: options ? stylix;
            })
          ];

        # Deliver stylix class to user's homeManager, or host targets
        stylix-to-user-scope = {
          host,
          user,
          ...
        }:
          lib.optionals
          (
            # Logic such that the inputs are used; just redundant sanity check
            (builtins.elem host.class ["nixos" "darwin" "homeManager"])
            && (
              (host.class == "homeManager")
              || (builtins.elem "homeManager" host.users."${user.userName}".classes)
            )
          )
          [
            (den.lib.policy.route {
              fromClass = "stylix";
              intoClass = "homeManager";
              intoPath = ["stylix"];
              guard = {options, ...}: options ? stylix;
            })
          ];
      };

      schema = {
        host = {
          includes = [
            den.policies.stylix-to-host-scope
            den.aspects.stylix.policies.stylix-host-dispatch
          ];
          options = {
            stylix = lib.mkOption {
              description = "Stylix options metadata";
              default = {};
              type = lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    description = "Enable stylix on this host";
                    default = true;
                    type = lib.types.bool;
                  };
                };
              };
            };
          };
        };
        user.includes = [
          den.policies.stylix-to-user-scope
        ];
      };

      # Stylix module
      aspects.stylix = {
        name = "stylix";

        # System level setup
        policies.stylix-host-dispatch = {host, ...}:
          lib.optional
          host.stylix.enable
          (den.lib.policy.include den.aspects.stylix);

        # Host level enables;
        os = {...}: {
          stylix = {
            enable = true;
            autoEnable = false;
          };
        };
        # Module loading, home-manager should only get enabled in standalone
        nixos = {...}: {
          imports = [
            inputs.stylix.nixosModules.stylix
          ];
        };
        darwin = {...}: {
          imports = [
            inputs.stylix.darwinModules.stylix
          ];
        };
        # Enable hm module only on HM only host
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
  };
}

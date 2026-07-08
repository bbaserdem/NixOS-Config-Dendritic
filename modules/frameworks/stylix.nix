{
  inputs,
  config,
  den,
  lib,
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
      # Selectable feature
      aspects.stylix = {
        # Shared enable semantics for both os classes
        os = {...}: {
          config = {
            stylix = {
              enable = true;
              autoEnable = false;
            };
          };
        };
        nixos = {...}: {
          imports = [inputs.stylix.nixosModules.stylix];
        };
        darwin = {...}: {
          imports = [inputs.stylix.darwinModules.stylix];
        };
        # Standalone only
        provides.standalone = {home}: {
          homeManager = {...}: {
            imports = [inputs.stylix.homeModules.stylix];
            stylix = {
              enable = true;
              autoEnable = false;
            };
          };
        };
      };

      # Intersection classes
      classes = {
        stylix.description = ''
          Stylix home-manager settings.
          Delivered to config.stylix only where stylix is loaded.
        '';
        stylixOs.description = ''
          Stylix nixos/nix-darwin settings.
          Delivered to config.stylix only where stylix is loaded.
        '';
      };

      policies = {
        stylixOs-route = {host, ...}:
          lib.optional (host ? class && builtins.elem host.class ["nixos" "darwin"]) (
            den.lib.policy.route {
              fromClass = "stylixOs";
              intoClass = host.class;
              intoPath = ["stylix"];
              guard = {options, ...}: options ? stylix;
            }
          );
        stylixHome-route = {...}: [
          (
            den.lib.policy.route {
              fromClass = "stylix";
              intoClass = "homeManager";
              intoPath = ["stylix"];
              guard = {options, ...}: options ? stylix;
            }
          )
        ];
      };

      default.includes = [
        den.policies.stylixOs-route
        den.policies.stylixHome-route
      ];
    };

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

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
      # We will add custom classes
      schema = let
        stylixFlag = {
          options.stylix.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable stylix themeing";
          };
        };
      in {
        host = stylixFlag;
        home = stylixFlag;
      };
      # We add custom classes to collect stylix settings
      classes = {
        stylix.description = "Home-manager stylix settings.";
        stylixOs.description = "Nixos/darwin stylix settings.";
      };
      policies = {
        stylix-enable = {...} @ ctx:
          lib.optional (
            # If home-standalone, check if entity has settings defined
            if (ctx ? home)
            then (ctx.home.stylix.enable or false)
            # If not home, then check if the host only aspect has stylix enabled
            # The base aspect should never go to user scopes
            else if ((ctx ? host) && !(ctx ? user))
            then (ctx.host.stylix.enable or false)
            else false
          ) (den.lib.policy.include den.aspects.stylix);
        # Inject the stylix module into relevant scope
        stylix-route = {...} @ ctx:
          lib.optional (
            # If home standalone; needs stylix settings defined
            if (ctx ? home)
            then (ctx.home.stylix.enable or false)
            # If not home, but in user context; host needs it defined
            else if ((ctx ? host) && (ctx ? user))
            then (ctx.host.stylix.enable or false)
            else false
          ) (
            den.lib.policy.route {
              fromClass = "stylix";
              intoClass = "homeManager";
              intoPath = [];
            }
          );
        stylixOs-route = {...} @ ctx:
          lib.optional (
            (lib.hasAttrByPath ["host" "class"] ctx)
            && (ctx.host.stylix.enable or false)
          ) (
            den.lib.policy.route {
              fromClass = "stylixOs";
              intoClass = ctx.host.class;
              intoPath = [];
            }
          );
      };
      default.includes = [
        den.policies.stylix-enable
        den.policies.stylix-route
        den.policies.stylixOs-route
      ];

      # Dispatchable feature
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

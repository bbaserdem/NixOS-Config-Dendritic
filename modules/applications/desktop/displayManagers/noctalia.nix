# Noctalia shell for desktops
{inputs, ...}: {
  # Den machinery; but shouldn't be needed
  den = {
    aspects.desktop = {
      provides.noctalia = {
        name = "desktop/noctalia";
        # OS level dispatch
        nixos = {...}: {
          imports = with inputs.self.modules.nixos; [
            noctalia
          ];
        };
        # User config
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/noctalia(${user.userName}@${host.name})";
          # Home-manager module
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              noctalia
            ];
          };
          # Stylix theming integration
          stylix = {
            # TODO: This is 26.11 release feature; uncomment after updating
            # targets.noctalia = {
            #   enable = true;
            # };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    nixos.noctalia = {pkgs, ...}: {
      key = "noctalia#nixos";
      # TODO: Pull noctalia module from 26.11; remove after migration
      imports = [
        "${inputs.nixpkgs-unstable}/nixos/modules/programs/wayland/noctalia.nix"
      ];
      config = {
        programs.noctalia = {
          enable = true;
          package = pkgs.unstable.noctalia;
          # Systemd should not be enabled without specifying target;
          # otherwise it start on all graphical sessions on all computers
        };
      };
    };

    # Home-Manager settings
    homeManager.noctalia = {
      lib,
      pkgs,
      ...
    } @ args: let
      # Flag for determining if noctalia is enabled on nixos module
      noctaliaIsNixosModule =
        (lib.hasAttrByPath ["osConfig" "programs" "noctalia"] args)
        && (args.osConfig.programs.noctalia.enable or false);
    in {
      key = "noctalia#homeManager";
      # TODO: Pull noctalia module from 26.11; remove after migration
      imports = [
        "${inputs.home-manager-unstable}/modules/programs/noctalia/default.nix"
      ];
      config = lib.mkMerge [
        ( # OS config from above
          lib.optionalAttrs noctaliaIsNixosModule {
            programs.noctalia = lib.mkMerge [
              {
                package = args.osConfig.programs.noctalia.package;
              }
              # If systemd enabled from top-down; disable systemd module
              (lib.mkIf args.osConfig.programs.noctalia.systemd.enable {
                systemd.enable = lib.mkOverride 90 false;
              })
            ];
          }
        )
        ( # Standalone home module
          lib.optionalAttrs (! noctaliaIsNixosModule) {
            programs.noctalia = {
              package = pkgs.unstable.noctalia;
            };
          }
        )
        {
          # Joint settings
          programs.noctalia = {
            enable = true;
            checkConfig = true;
            # Systemd module hooks directly to config.wayland.systemd.target
            # I don't like this; shouldn't use the home-manager systemd module
            systemd.enable = lib.mkDefault false;
          };
        }
      ];
    };
  };
}

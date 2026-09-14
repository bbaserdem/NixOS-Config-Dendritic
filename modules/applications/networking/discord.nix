# Discord through nixcord
{inputs, ...}: {
  # Flake source for nixcord
  flake-file = {
    inputs.nixcord = {
      url = "github:4evy/nixcord";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-nixcord.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        nix-darwin.follows = "nix-darwin";
      };
    };
  };

  # Den integration
  den = {
    aspects.applications.provides.discord = {
      provides.to-users = {
        user,
        host,
      }: {
        # Dedupe and name usage
        name = "applications/discord(${user.userName}@${host.name})";
        # Darwin needs to install by brew
        darwin = {...}: {
          imports = [
            inputs.self.modules.darwin.discord-settings
          ];
        };
        homeManager = {...}: {
          imports = [
            inputs.self.modules.homeManager.discord-settings
          ];
        };
        stylix = {
          targets.nixcord = {
            enable = true;
            colors.enable = true;
            fonts.enable = true;
          };
        };
      };
    };
  };

  # In darwin, install legcord from homebrew instead
  flake.modules.darwin.discord-settings = {...}: {
    key = "discord-settings#darwin";
    config = {
      homebrew.casks = ["legcord"];
    };
  };

  # Home-Manager module
  flake.modules.homeManager.discord-settings = {
    pkgs,
    lib,
    options,
    ...
  }: {
    key = "discord-settings#homeManager";
    imports = [
      (inputs.nixcord.homeModules.nixcord or {})
    ];

    config = lib.optionalAttrs (options.programs ? nixcord) (
      lib.mkMerge [
        {
          # Enable discord we only want to use one frontend
          programs.nixcord = {
            enable = true;

            discord = {
              # Disable the built-in client
              enable = false;
              # Do not want vencord
              vencord.enable = false;
              # Do want equicord
              equicord = {
                enable = true;
                package = pkgs.unstable.equicord;
              };
            };

            # Use Legcord as frontend
            legcord = {
              enable = true;
              equicord.enable = true;
            };

            # Common config
            config = {
              frameless = true;
              transparent = true;
              disableMinSize = true;
            };
          };
        }
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            # We install from nixpkgs
            programs.nixcord.legcord = {
              package = pkgs.unstable.legcord;
              installPackage = true;
            };
          }
        )
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
            # We install from brew, nixpkgs legcord doesn't build for darwin
            programs.nixcord.legcord = {
              installPackage = false;
            };
          }
        )
      ]
    );
  };
}

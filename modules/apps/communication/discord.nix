# Discord through nixcord
{inputs, ...}: {
  # Flake source for nixcord
  flake-file = {
    inputs.nixcord.url = "github:FlameFlag/nixcord";
  };

  flake.modules = {
    # In darwin, install legcord from homebrew instead
    darwin.discord = {...}: {
      homebrew = {
        casks = [
          "legcord"
        ];
      };
    };

    # Home-Manager modules
    homeManager = {
      # Enable stylix theming
      stylix = {...}: {
        stylix.targets.nixcord = {
          enable = true;
          colors.enable = true;
          fonts.enable = true;
        };
      };

      # Enable discord
      discord = {
        pkgs,
        lib,
        ...
      }: {
        imports = [
          inputs.nixcord.homeModules.nixcord
        ];

        config = lib.mkMerge [
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
        ];
      };
    };
  };
}

# Discord through nixcord
{inputs, ...}: {
  # Flake source for nixcord
  flake-file = {
    inputs.nixcord.url = "github:FlameFlag/nixcord";
  };

  flake.modules.homeManager = {
    # Enable stylix theming
    stylix = {...}: {
      stylix.targets = {
        nixcord.enable = true;
        vencord.enable = true;
        vesktop.enable = true;
      };
    };

    # Enable discord
    discord = {pkgs, ...}: {
      imports = [
        inputs.nixcord.homeModules.nixcord
      ];

      config = {
        # Enable vencord
        programs.nixcord = {
          enable = true;

          # Get vesktop without discord
          discord = {
            enable = false;
            vencord = {
              enable = true;
              package = pkgs.unstable.vencord;
              #unstable = true;
            };
            openASAR.enable = true;
          };

          vesktop = {
            enable = true;
            # package = pkgs.unstable.vesktop;
          };
        };
      };
    };
  };
}

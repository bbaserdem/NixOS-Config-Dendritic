# Nix settings
{inputs, ...}: {
  flake.modules = {
    # Modules to setup the nix daemon

    # Nixos module; for nixos specific nix settings
    nixos.nix = {...}: {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
      ];

      config = {
        # Garbage collect settings
        nix = {
          nixPath = ["nixpkgs=${inputs.nixpkgs}"];
          gc.automatic = true;
          settings.auto-optimise-store = true;
        };
        programs = {
          # Linux-specific configuration
          nix-ld.enable = true;
          nix-index = {
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
          };
        };
      };
    };

    # Darwin module; for darwin specific settings
    darwin.nix = {...}: {
      imports = [
        inputs.nix-index-database.darwinModules.nix-index
      ];

      config = {
        nix = {
          nixPath = ["nixpkgs=${inputs.nixpkgs-darwin}"];
          optimise.automatic = true;
          enable = true;
          gc.interval = [
            {
              Hour = 3;
              Minute = 15;
              Weekday = 7;
            }
          ];

          # Enable cross-comp
          linux-builder.enable = true;
          settings.trusted-users = ["@admin"];
        };
      };
    };

    # Generic; for nix settings for both nixos and darwin contexts
    generic.nix = {pkgs, ...}: {
      config = {
        # Package manager config
        nix = {
          gc.options = "--delete-older-than 60d";
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
              "pipe-operators"
              "ca-derivations"
            ];
            # For dev related things
            keep-outputs = true;
            keep-derivations = true;
          };
        };

        programs = {
          nix-index.enable = true;
          nix-index-database.comma.enable = true;
        };

        # Nix helper utilities
        environment.systemPackages = with pkgs; [
          nh
          nix-output-monitor
          nvd
          sops
        ];
      };
    };

    # Home-manager; add nix-index to hm
    homeManager.nix = {pkgs, ...}: {
      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      programs = {
        nix-index-database.comma.enable = true;
        nix-index = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableFishIntegration = true;
          enableNushellIntegration = true;
        };
      };
    };
  };
}

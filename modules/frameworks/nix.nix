# Nix deamon settings
{
  inputs,
  den,
  ...
}: {
  config = {
    # Auto-database fetching
    flake-file.inputs.nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    den = {
      aspects.nix = {
        # Both OS classes
        os = {...}: {
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
        };
        nixos = {...}: {
          # Garbage collect settings
          nix = {
            nixPath = ["nixpkgs=${inputs.nixpkgs}"];
            gc.automatic = true;
            settings.auto-optimise-store = true;
          };
        };
        darwin = {...}: {
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

        # Extras: tooling and conveniences selected per host
        provides.extras = {
          os = {pkgs, ...}: {
            programs = {
              nix-index.enable = true;
              nix-index-database.comma.enable = true;
            }; # Nix helper utilities
            environment.systemPackages = with pkgs; [
              nh
              nix-output-monitor
              nvd
              nix-diff
              nix-weather
            ];
          };
          nixos = {...}: {
            imports = [inputs.nix-index-database.nixosModules.nix-index];
            config = {
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
          darwin = {...}: {
            imports = [inputs.nix-index-database.darwinModules.nix-index];
          };

          # Selecting extras on host propagates to it's users
          provides = {
            to-users.includes = [den.aspects.nix.provides.extras.provides.home];
            home = {
              homeManager = {...}: {
                imports = [inputs.nix-index-database.homeModules.default];
                config = {
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
            };
          };
        };
      };

      # Fleet invariant, dispatched to everyone
      schema = {
        host.includes = [den.aspects.nix];
      };
    };

    # Old flake-parts
    flake = {
      modules = {
        # Modules to setup the nix daemon

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
              nix-diff
              nix-weather
            ];
          };
        };

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

        # Home-manager; add nix-index to hm
        homeManager.nix = {...}: {
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
    };
  };
}

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

    # Nix configuration aspect
    den = {
      aspects.nix = let
        # Settings shared across ALL contexts
        nixShared = {
          settings = {
            auto-optimise-store = true;
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
          gc = {
            automatic = true;
            options = "--delete-older-than 60d";
          };
        };
      in {
        # Both OS classes
        os = {...}: {
          nix = nixShared;
        };
        nixos = {...}: {
          # Garbage collect settings
          nix = {
            nixPath = ["nixpkgs=${inputs.nixpkgs}"];
            optimise = {
              automatic = true;
              dates = "weekly";
            };
            gc.dates = "weekly";
          };
        };
        darwin = {...}: {
          nix = {
            # Let nix manage itself
            enable = true;
            nixPath = ["nixpkgs=${inputs.nixpkgs-darwin}"];
            optimise = {
              automatic = true;
              interval = [
                {
                  Hour = 4;
                  Minute = 15;
                  Weekday = 7;
                }
              ];
            };
            gc.interval = [
              {
                Hour = 3;
                Minute = 15;
                Weekday = 7;
              }
            ];
            # Enable cross-comp
            linux-builder.enable = true;
            settings.trusted-users = ["@admin" "@builders" "@staff"];
          };
        };

        # Extras: tooling and conveniences selected per host
        includes = [den.aspects.nix.provides.standalone];
        provides.standalone = {home}: {
          homeManager = {
            lib,
            pkgs,
            ...
          }: {
            nix = lib.recursiveUpdate nixShared {
              package = pkgs.nix;
              nixPath = ["nixpkgs=${inputs.nixpkgs}"];
              gc.dates = "weekly";
            };
          };
        };

        # Extras to be provided
        provides.extras = let
          hmNixModule = {...}: {
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
        in {
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
          # Selecting extras on host propagates, or on home also stays
          homeManager = hmNixModule;
          provides.to-users = {homeManager = hmNixModule;};
        };
      };

      # Fleet invariant, base aspect should be dispatched to everyone
      # Don't walk in default; because user walk up would duplicate.
      schema = {
        host.includes = [den.aspects.nix];
        home.includes = [den.aspects.nix];
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

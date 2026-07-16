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
      aspects.nix = {
        # Shared settings
        os = {...}: {
          imports = [
            inputs.self.modules.generic.nix-common
          ];
        };
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.nix-common
          ];
        };
        darwin = {...}: {
          imports = [
            inputs.self.modules.darwin.nix-common
          ];
        };

        # Extras: tooling and conveniences selected per host
        # (Guard in realizing this only in hm-as-standalone scope with parametric)
        includes = [den.aspects.nix._.standalone];
        provides.standalone = {home}: {
          homeManager = {...}: {
            imports = [
              inputs.self.modules.generic.nix-common
              inputs.self.modules.homeManager.nix-common
            ];
          };
        };

        # Extras to be provided
        extras = {
          os = {...}: {
            imports = [
              inputs.self.modules.generic.nix-extras
            ];
          };
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nix-extras
            ];
          };
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.nix-extras
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.nix-extras
            ];
          };
          # Selecting extras on host propagates, or on home also stays
          provides.to-users = {
            homeManager = {...}: {
              imports = [inputs.self.modules.homeManager.nix-extras];
            };
          };
        };
      };

      # Fleet invariant, base aspect should be dispatched to everyone
      # Don't walk in default, user walk up would duplicate the scope.
      schema = {
        host.includes = [den.aspects.nix];
        home.includes = [den.aspects.nix];
      };
    };

    # Old flake-parts
    flake = {
      modules = {
        # Module for common settings to the nix daemon; all contexnt
        generic = {
          nix-common = {...}: {
            nix = {
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
          };
          nix-extras = {pkgs, ...}: {
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
        };
        nixos = {
          nix-common = {...}: {
            nix = {
              # Set the nixpkgs source for legacy nix tooling
              nixPath = ["nixpkgs=${inputs.nixpkgs}"];
              # Garbage collect settings
              optimise = {
                automatic = true;
                dates = "weekly";
              };
              gc.dates = "weekly";
            };
          };
          nix-extras = {...}: {
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
        };
        darwin = {
          nix-common = {...}: {
            nix = {
              # Let nix manage itself (?)
              enable = true;
              # Set the nixpkgs source for legacy nix tooling
              nixPath = ["nixpkgs=${inputs.nixpkgs-darwin}"];
              # Garbage collect settings; darwin specific
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
              # Enable cross-compilation
              linux-builder.enable = true;
              # Darwin trusted settings
              settings.trusted-users = ["@admin" "@builders" "@staff"];
            };
          };
          nix-extras = {...}: {
            imports = [inputs.nix-index-database.darwinModules.nix-index];
          };
        };
        homeManager = {
          nix-common = {pkgs, ...}: {
            nix = {
              package = pkgs.nix;
              nixPath = ["nixpkgs=${inputs.nixpkgs}"];
              gc.dates = "weekly";
            };
          };
          nix-extras = {...}: {
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

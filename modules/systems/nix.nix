# Nix deamon settings
{
  inputs,
  den,
  lib,
  config,
  ...
}: let
  nixCfg = config.nixpkgs;
in {
  # Auto-database fetching
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den = {
    # Everyone gets us
    schema = {
      host = {
        includes = [
          den.aspects.system._.nix
          den.aspects.system._.nix.policies.nix-extras-host-dispatch
        ];
        options = {
          nix = lib.mkOption {
            description = "Nix daemon metadata";
            default = {};
            type = lib.types.submodule {
              options = {
                extras = lib.mkOption {
                  description = "Enable extra nix tooling on this host.";
                  default = true;
                  type = lib.types.bool;
                };
              };
            };
          };
        };
      };
      user = {
        includes = [
          den.aspects.system._.nix.policies.nix-extras-user-dispatch
        ];
      };
    };

    aspects.system = {
      provides.nix = {
        name = "system/nix";
        policies = {
          nix-extras-host-dispatch = {host, ...}:
            lib.optional
            host.nix.extras
            (den.lib.policy.include den.aspects.system._.nix._.extras);
          nix-extras-user-dispatch = {host, ...}:
            lib.optional
            host.nix.extras
            (den.lib.policy.include den.aspects.system._.nix._.extras._.to-users);
        };

        # Base modules
        os = {...}: {
          imports = [
            inputs.self.modules.generic.nix-base
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
        homeManager = {...}: {
          imports = [
            inputs.self.modules.generic.nix-base
          ];
        };
        provides.to-users = {
          user,
          host,
        }: {
          name = "system/nix(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              # This specific generic module is common for os and hm
              inputs.self.modules.generic.nix-common
              inputs.self.modules.homeManager.nix-common
            ];
          };
        };

        # Extras modules
        provides.extras = {
          name = "system/nix/extras";
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
          provides.to-users = {
            user,
            host,
          }: {
            name = "system/nix/extras(${user.userName}@${host.name})";
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.nix-extras
              ];
            };
          };
        };
      };
    };
  };

  flake = {
    modules = let
      nixExtraPackages = pkgs: (with pkgs; [
        nh
        nix-output-monitor
        nvd
        nix-diff
        nix-weather
      ]);
    in {
      # Shared base module only darwin, nixos and standalone hm
      generic = {
        nix-base = {
          lib,
          pkgs,
          ...
        }: {
          key = "nix-base#generic";
          config = {
            nixpkgs = {
              inherit (nixCfg) config overlays;
            };
            nix = {
              # This is set by default in den; but redo
              package = lib.mkDefault pkgs.nix;
            };
          };
        };

        # Nix common is shared across all; nixos, darwin, home-manager
        nix-common = {
          lib,
          options,
          config,
          ...
        }: {
          key = "nix-common#generic";
          config = lib.mkMerge [
            {
              nix = {
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
                  # User trust with groups
                  trusted-users = [
                    "@nix"
                    "@wheel"
                  ];
                  auto-optimise-store = true;
                };
                gc = {
                  automatic = true;
                  options = "--delete-older-than 60d";
                };
              };
            }
            (
              # SOPS auth token
              lib.optionalAttrs (options ? sops) (
                let
                  tokens = {
                    github = "github.com";
                  };
                in {
                  sops = {
                    secrets =
                      tokens
                      |> lib.mapAttrs' (
                        name: url:
                          lib.nameValuePair
                          "nix-tokens/${name}"
                          {
                            sopsFile = inputs.self + /secrets/secrets.yaml;
                          }
                      );
                    templates."nix-tokens.conf" = {
                      content =
                        tokens
                        |> lib.mapAttrsToList (
                          name: url: "extra-access-tokens = ${url}=${config.sops.placeholder."nix-tokens/${name}"}"
                        )
                        |> builtins.concatStringsSep "\n";
                    };
                  };
                  # Push to nix
                  nix.extraOptions = ''
                    !include ${config.sops.templates."nix-tokens.conf".path}
                  '';
                }
              )
            )
          ];
        };
        # Shared between nixos, darwin
        nix-extras = {pkgs, ...}: {
          key = "nix-extras#generic";
          config = {
            programs = {
              nix-index.enable = true;
              nix-index-database.comma.enable = true;
            };
            # Nix helper utilities
            environment.systemPackages = nixExtraPackages pkgs;
          };
        };
      };

      # Nixos modules
      nixos = {
        nix-common = {...}: {
          key = "nix-common#nixos";
          config = {
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
        };
        nix-extras = {...}: {
          key = "nix-extras#nixos";
          imports = [
            inputs.nix-index-database.nixosModules.nix-index
          ];
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

      # Darwin modules
      darwin = {
        nix-common = {...}: {
          key = "nix-common#darwin";
          config = {
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
              settings.trusted-users = [
                "@admin"
                "@builders"
              ];
            };
          };
        };
        nix-extras = {...}: {
          key = "nix-extras#darwin";
          imports = [
            inputs.nix-index-database.darwinModules.nix-index
          ];
        };
      };

      # Home-manager modules
      homeManager = {
        nix-common = {...}: {
          key = "nix-common#homeManager";
          config = {
            nix = {
              nixPath = ["nixpkgs=${inputs.nixpkgs}"];
              gc.dates = "weekly";
            };
          };
        };
        nix-extras = {pkgs, ...}: {
          key = "nix-extras#homeManager";
          imports = [
            inputs.nix-index-database.homeModules.default
          ];
          config = {
            programs = {
              nix-index = {
                enable = true;
                enableBashIntegration = true;
                enableZshIntegration = true;
                enableFishIntegration = true;
                enableNushellIntegration = true;
              };
              nix-index-database.comma.enable = true;
            };
            # Tooling
            home.packages = nixExtraPackages pkgs;
          };
        };
      };
    };
  };
}

# Sops nix for secrets dispatch
{
  inputs,
  lib,
  den,
  ...
}: {
  config = {
    # Import sops-nix flake
    flake-file.inputs = {
      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    den = {
      # Schema defins for concerned entities
      schema = {
        host = {config, ...}: {
          options.secrets = {
            sopsFile = lib.mkOption {
              type = lib.types.path;
              default =
                inputs.self
                + "/secrets/host/${config.name}/secrets.yaml";
              description = "Default sops file for this host.";
            };
          };
        };
        user = {config, ...}: {
          options.secrets = {
            sopsFile = lib.mkOption {
              type = lib.types.path;
              default =
                inputs.self
                + "/secrets/user/${config.name}/secrets.yaml";
              description = "Default sops file for this user.";
            };
          };
        };
        home = {config, ...}: {
          options.secrets = {
            sopsFile = lib.mkOption {
              type = lib.types.path;
              default =
                if (config.hostName != null)
                then (inputs.self + "/secrets/host/${config.hostName}/secrets.yaml")
                else (inputs.self + "/secrets/user/${config.userName}/secrets.yaml");
              description = "Default sops file for this user.";
            };
          };
        };
      };

      aspects.secrets = {
        includes = [
          den.aspects.secrets._.host
          den.aspects.secrets._.standalone
        ];

        provides.host = {host}: {
          # Generic dispatch to darwin and nixos
          os = {...}: {
            config = {
              sops = {
                defaultSopsFile = host.secrets.sopsFile;
                age = {
                  sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
                  generateKey = false;
                };
              };
            };
          };
          # Nixos specific dispatch
          nixos = {...}: {
            imports = [inputs.sops-nix.nixosModules.sops];
            config = {
              sops.useSystemdActivation = true;
            };
          };
          # Darwin specific dispatch
          darwin = {...}: {
            imports = [inputs.sops-nix.darwinModules.sops];
          };
        };

        # The fan-out to managed users
        provides.to-users = {user}: {
          homeManager = {
            config,
            lib,
            pkgs,
            ...
          }: {
            imports = [inputs.sops-nix.homeModules.sops];
            config = lib.mkMerge [
              {
                # Home-manager sops dispatch
                sops = {
                  defaultSopsFile = user.secrets.sopsFile;
                  age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
                };
              }
              (
                # In darwin default location is in application support
                lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
                  home.file."Library/Application Support/sops" = {
                    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/sops";
                    force = true;
                  };
                }
              )
            ];
          };
        };

        provides.standalone = {home}: {
          homeManager = {
            config,
            lib,
            pkgs,
            ...
          }: {
            imports = [inputs.sops-nix.homeModules.sops];
            config = lib.mkMerge [
              {
                # Home-manager sops dispatch
                sops = {
                  defaultSopsFile = home.secrets.sopsFile;
                  age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
                };
              }
              (
                # In darwin default location is in application support
                lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
                  home.file."Library/Application Support/sops" = {
                    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/sops";
                    force = true;
                  };
                }
              )
            ];
          };
        };
      };
    };

    # Old flake-parts stuff
    # Load into contexts, generic gets loaded into nixos and darwin settings
    flake.modules = {
      generic.secrets = {config, ...}: {
        # Default ssh key locations
        sops = {
          defaultSopsFile = inputs.self + /secrets/host/${config.networking.hostName}/secrets.yaml;
          age = {
            sshKeyPaths = [
              "/etc/ssh/ssh_host_ed25519_key"
            ];
            generateKey = false;
          };
        };
      };
      nixos.secrets = {...}: {
        imports = [
          inputs.sops-nix.nixosModules.sops
        ];
        sops = {
          # Use systemd for decryption
          useSystemdActivation = true;
        };
      };
      darwin.secrets = {...}: {
        imports = [
          inputs.sops-nix.darwinModules.sops
        ];
      };
      homeManager.secrets = {
        config,
        pkgs,
        lib,
        ...
      }: {
        imports = [
          inputs.sops-nix.homeModules.sops
        ];

        config = lib.mkMerge [
          {
            # Default key file location; where age keys are, etc
            sops = {
              defaultSopsFile = inputs.self + /secrets/user/${config.home.username}/secrets.yaml;
              age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
            };
          }
          (
            # Drop a symlink in the canonical directory in macos
            lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
              home.file."Library/Application Support/sops" = {
                source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/sops";
                force = true;
              };
            }
          )
        ];
      };
    };
  };
}

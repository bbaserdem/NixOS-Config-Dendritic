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
      # Schema defines for concerned entities
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
          den.aspects.secrets.provides.for-hosts
          den.aspects.secrets.provides.for-homes
        ];

        os = {...}: {
          imports = [inputs.self.modules.generic.sops];
        };
        nixos = {...}: {
          imports = [inputs.self.modules.nixos.sops];
        };
        darwin = {...}: {
          imports = [inputs.self.modules.darwin.sops];
        };

        # Generic dispatch to default key file, parametric on host scopes
        # (Fires on standalone hm due to virtual host, but os module isn't used)
        provides.for-hosts = {host}: {
          os = {...}: {
            sops.defaultSopsFile = host.secrets.sopsFile;
          };
        };

        # Dispatch default key file to standalone hm, parametric on home scopes
        provides.for-homes = {home}: {
          homeManager = {lib, ...}: {
            imports = [inputs.self.modules.homeManager.sops];
            config = {
              sops.defaultSopsFile = lib.mkOverride 900 home.secrets.sopsFile;
            };
          };
        };

        # The (auto) fan-out to managed users; dispatch sops secret location
        provides.to-users = {
          host,
          user,
        }: {
          homeManager = {lib, ...}: {
            imports = [inputs.self.modules.homeManager.sops];
            config = {
              sops.defaultSopsFile = lib.mkOverride 950 user.secrets.sopsFile;
            };
          };
        };
      };
    };

    flake.modules = {
      # Modules to dispatch
      generic.sops = {...}: {
        key = "frameworks-sops#os";
        config = {
          sops = {
            age = {
              sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              generateKey = false;
            };
          };
        };
      };
      nixos.sops = {...}: {
        key = "frameworks-sops#nixos";
        imports = [inputs.sops-nix.nixosModules.sops];
        config = {
          sops.useSystemdActivation = true;
        };
      };
      darwin.sops = {...}: {
        key = "frameworks-sops#darwin";
        imports = [inputs.sops-nix.darwinModules.sops];
      };
      homeManager.sops = {
        config,
        pkgs,
        lib,
        ...
      }: {
        key = "frameworks-sops#hm";
        imports = [
          inputs.sops-nix.homeModules.sops
        ];
        config = lib.mkMerge [
          {
            # Keyfile location
            sops = {
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

      # Old flake-parts stuff
      # Load into contexts, generic gets loaded into nixos and darwin settings
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

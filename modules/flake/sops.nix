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
      sops-nix.url = "github:Mic92/sops-nix";
    };

    # Den machinery
    den = {
      # Schema defines for concerned entities
      schema = {
        host = {
          includes = [
            den.aspects.sops.policies.sops-host-dispatch
          ];
          imports = [
            ({config, ...}: {
              options = {
                sops = lib.mkOption {
                  description = "SOPS secrets dispatch metadata";
                  default = {};
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        description = "Enable sops-nix on this host";
                        default = true;
                        type = lib.types.bool;
                      };
                      sopsFile = lib.mkOption {
                        description = "Default sops file for this host.";
                        default =
                          inputs.self
                          + "/secrets/host/${config.name}/secrets.yaml";
                        type = lib.types.path;
                      };
                    };
                  };
                };
              };
            })
          ];
        };
        user = {
          includes = [
            den.aspects.sops.policies.sops-user-dispatch
          ];
          imports = [
            ({config, ...}: {
              options = {
                sops = lib.mkOption {
                  description = "SOPS secrets dispatch metadata";
                  default = {};
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        description = "Enable sops-nix on this host";
                        default = true;
                        type = lib.types.bool;
                      };
                      sopsFile = lib.mkOption {
                        description = "Default sops file for this user.";
                        default =
                          inputs.self
                          + "/secrets/user/${config.name}/secrets.yaml";
                        type = lib.types.path;
                      };
                    };
                  };
                };
              };
            })
          ];
        };
      };

      aspects.sops = {
        name = "sops";
        policies = {
          sops-host-dispatch = {host, ...}:
            lib.optional
            host.sops.enable
            (den.lib.policy.include den.aspects.sops._.host-setup);
          sops-user-dispatch = {
            host,
            user,
            ...
          }:
            lib.optional
            (host.sops.enable && user.sops.enable)
            (den.lib.policy.include den.aspects.sops._.user-setup);
        };

        # Host-specific module
        provides.host-setup = {host}: {
          name = "sops(@${host.name})";
          os = {...}: {
            imports = [
              inputs.self.modules.generic.sops
            ];
            config = {
              # Set the default sops file in the system for OS outputs
              sops.defaultSopsFile = host.sops.sopsFile;
            };
          };
          # We don't deliberately set homeManager only outputs' sops default file
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.sops
            ];
          };
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.sops
            ];
          };
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.sops
            ];
          };
        };

        # User specific setup
        provides.user-setup = {
          host,
          user,
        }: {
          name = "sops(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [inputs.self.modules.homeManager.sops];
            config = {
              # Set the default sops file in home-manager
              sops.defaultSopsFile = user.sops.sopsFile;
            };
          };
        };
      };
    };

    flake.modules = {
      # Modules to dispatch
      generic.sops = {...}: {
        key = "sops#os";
        config = {
          sops.age = {
            sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
            generateKey = false;
          };
        };
      };
      nixos.sops = {...}: {
        key = "frameworks-sops#nixos";
        imports = [
          inputs.sops-nix.nixosModules.sops
        ];
        config = {
          sops.useSystemdActivation = true;
        };
      };
      darwin.sops = {...}: {
        key = "frameworks-sops#darwin";
        imports = [
          inputs.sops-nix.darwinModules.sops
        ];
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
    };
  };
}

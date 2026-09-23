# Configuring container backends
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    classes.containerization.description = "Sets a user up for containerization";
    schema = {
      host = {
        includes = [
          den.aspects.containerization.policies.containerization-host-dispatch
        ];
        imports = [
          ({config, ...}: {
            options = {
              containerization = lib.mkOption {
                description = "Containerization metadata on this host";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Whether to enable containerization on this host";
                      default = false;
                      type = lib.types.bool;
                      apply = flag:
                        if (builtins.elem config.class ["nixos" "darwin"])
                        then flag
                        else false;
                    };
                    backend = lib.mkOption {
                      description = "Backend to use for containerization";
                      default =
                        if config.class == "nixos"
                        then "podman"
                        else if config.class == "darwin"
                        then "orbstack"
                        else null;
                      type = lib.types.nullOr (lib.types.enum [
                        "podman"
                        "orbstack"
                      ]);
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
          den.aspects.containerization.policies.containerization-user-dispatch
        ];
      };
    };

    aspects.containerization = {
      # Enable the proper aspect on a given host
      policies.containerization-host-dispatch = {host, ...}: let
        cfg = host.containerization;
      in (
        lib.optional
        cfg.enable
        (den.lib.policy.include den.aspects.containerization._.${cfg.backend})
      );
      # If applicable, configure the user
      policies.containerization-user-dispatch = {
        host,
        user,
        ...
      }: (
        lib.optional
        (host.containerization.enable && (builtins.elem "containerization" user.classes))
        (den.lib.policy.include den.aspects.containerization._.to-users)
      );

      provides.podman = {
        # Enable podman in nixos
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.containerization-podman
          ];
        };
      };

      provides.orbstack = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "containerization/orbstack(${user.userName}@${host.name})";
          # Enable orbstack in darwin hm
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.containerization-orbstack
            ];
          };
        };
      };

      # User setup
      provides.to-users = {
        host,
        user,
      }: {
        name = "containerization(${user.userName}@${host.name})";
        user = {
          lib,
          osConfig,
          ...
        }:
          lib.optionalAttrs (host.class == "nixos") {
            extraGroups =
              [
                "docker"
              ]
              |> builtins.filter (n: lib.hasAttrByPath ["users" "groups" n] osConfig);
          };
      };
    };
  };

  # Use podman in linux
  flake.modules.nixos.containerization-podman = {pkgs, ...}: {
    key = "containerization-podman#nixos";
    config = {
      # Setup podman for nixos
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
          driver = "bridge";
        };
      };
      # Add podman-compose
      environment.systemPackages = with pkgs; [
        podman-compose
      ];
    };
  };

  # Use orbstack in darwin; in userspace
  flake.modules.homeManager.containerization-orbstack = {
    pkgs,
    lib,
    ...
  }: {
    key = "containerization-orbstack#homeManager";
    config = lib.mkMerge [
      (
        # Darwin guard
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          home.packages = with pkgs; [
            orbstack
          ];
        }
      )
    ];
  };
}

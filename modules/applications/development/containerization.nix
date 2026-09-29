# Configuring container backends
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    # Define a user class to be added to docker group
    classes.containerization.description = "Sets a user up for containerization";
    # Add to schema enables
    schema = {
      host = {
        includes = [
          den.aspects.development.policies.containerization-host-dispatch
        ];
        imports = [
          ({config, ...}: {
            options = {
              development = lib.mkOption {
                type = lib.types.submodule {
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
                };
              };
            };
          })
        ];
      };
      user = {
        includes = [
          den.aspects.development.policies.containerization-user-dispatch
        ];
      };
    };

    aspects.development = {
      # Enable the proper aspect on a given host
      policies.containerization-host-dispatch = {host, ...}: (
        lib.optionals
        host.development.containerization.enable
        [
          (
            den.lib.policy.include
            den.aspects.development._.containerization
          )
        ]
        ++ (
          lib.optional
          (host.development.containerization.backend != null)
          (
            den.lib.policy.include
            den.aspects.development._.containerization._.${host.development.containerization.backend}
          )
        )
      );
      # Configure the user account if in proper class
      policies.containerization-user-dispatch = {
        host,
        user,
        ...
      }: (
        lib.optionals
        (
          host.development.containerization.enable
          && (builtins.elem "containerization" user.classes)
        )
        [
          (
            den.lib.policy.include
            den.aspects.development._.containerization._.user-setup
          )
        ]
      );
      # Aspect
      provides.containerization = {
        name = "development/containerization";
        # Podman for docker backend
        provides.podman = {
          name = "development/containerization/podman";
          # Enable podman in nixos
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.containerization-podman
            ];
          };
        };
        # Orbstack for darwin; goes to userspace
        provides.orbstack = {
          name = "development/containerization/orbstack";
          provides.to-users = {
            host,
            user,
          }: {
            name = "development/containerization/orbstack(${user.userName}@${host.name})";
            # Enable orbstack in darwin hm
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.containerization-orbstack
              ];
            };
          };
        };
        # Setup for users
        provides.user-setup = {
          host,
          user,
        }: {
          name = "development/containerization/user-setup(${user.userName}@${host.name})";
          user = {
            lib,
            osConfig,
            ...
          }:
            lib.optionalAttrs (host.class == "nixos") {
              # In nixos, add to relevant groups
              extraGroups =
                [
                  "docker"
                ]
                |> builtins.filter (n: lib.hasAttrByPath ["users" "groups" n] osConfig);
            };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    nixos.containerization-podman = {pkgs, ...}: {
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
    homeManager.containerization-orbstack = {
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
  };
}

# Virtualization setup
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    # Define class to add a user to for virtualization access
    classes.virtualization.description = "Sets a user up for virtualization";
    # Add to schema enables
    schema = {
      host = {
        includes = [
          den.aspects.development.policies.virtualization-host-dispatch
        ];
        imports = [
          ({config, ...}: {
            options = {
              development = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    virtualization = lib.mkOption {
                      description = "Virtualization metadata on this host";
                      default = {};
                      type = lib.types.submodule {
                        options = {
                          enable = lib.mkOption {
                            description = "Whether to enable virtualization on this host.";
                            default = false;
                            type = lib.types.bool;
                            # Enforce type when not of OS class
                            apply = flag:
                              if (builtins.elem config.class ["nixos" "darwin"])
                              then flag
                              else false;
                          };
                          hypervisor = lib.mkOption {
                            description = "Which hypervisor to use.";
                            default =
                              if (config.class == "nixos")
                              then "libvirt"
                              else if (config.class == "darwin")
                              then "utm"
                              else null;
                            type = lib.types.nullOr (lib.types.enum [
                              "libvirt"
                              "utm"
                            ]);
                          };
                          windows = lib.mkOption {
                            description = "Whether to install windows guest drivers.";
                            default = true;
                            type = lib.types.bool;
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
          den.aspects.development.policies.virtualization-user-dispatch
        ];
      };
    };

    aspects.development = {
      # Policy for dispatching virtualization setup to host
      policies.virtualization-host-dispatch = {host, ...}:
        lib.optionals
        host.development.virtualization.enable
        (
          [
            (den.lib.policy.include den.aspects.development._.virtualization)
          ]
          ++ ( # Provide windows drivers if needed
            lib.optional
            host.development.virtualization.windows
            (
              den.lib.policy.include
              den.aspects.development._.virtualization._.windows
            )
          )
          ++ ( # Set up the hypervisor
            lib.optional
            (host.development.virtualization.hypervisor != null)
            (
              den.lib.policy.include
              den.aspects.development._.virtualization._.${host.development.virtualization.hypervisor}
            )
          )
        );
      # Policy for configuring user for using virtualization
      policies.virtualization-user-dispatch = {
        host,
        user,
        ...
      }:
        lib.optionals
        (
          host.development.virtualization.enable
          && (builtins.elem "virtualization" user.classes)
        )
        (
          []
          ++ ( # If backend is libvirtd; set up enabled users
            lib.optional
            (host.development.virtualization.hypervisor == "libvirt")
            (
              den.lib.policy.include
              den.aspects.development._.virtualization._.libvirt._.user-setup
            )
          )
          ++ ( # If backend is utm; set up enabled users
            lib.optional
            (host.development.virtualization.hypervisor == "utm")
            (
              den.lib.policy.include
              den.aspects.development._.virtualization._.utm._.user-setup
            )
          )
        );

      # Aspect
      provides.virtualization = {
        name = "development/virtualization";

        # Libvirt for hypervisor management
        provides.libvirt = {
          name = "development/virtualization/libvirt";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.virtualization-libvirt
            ];
          };
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.virtualization-libvirt
            ];
          };
          # Standalone also gets homeManager module
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.virtualization-libvirt
            ];
          };
          # User setup for users that opted in
          provides.user-setup = {
            host,
            user,
          }: {
            name = "development/virtualization/libvirt/user-setup(${user.userName}@${host.name})";
            # Gets the libvirtd module; deduped on homeManager hosts by module key
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.virtualization-libvirt
              ];
            };
            # Gets assigned user groups
            user = {
              lib,
              osConfig,
              ...
            }:
              lib.optionalAttrs (host.class == "nixos") {
                extraGroups =
                  [
                    "libvirtd"
                    "libvirtd-qemu"
                  ]
                  |> builtins.filter (n: lib.hasAttrByPath ["users" "groups" n] osConfig);
              };
          };
        };

        # UTM for hypervisor
        provides.utm = {
          name = "development/virtualization/utm";
          # No system-wide setup
          # User setup for users that opted in
          provides.user-setup = {
            host,
            user,
          }: {
            name = "development/virtualization/utm/user-setup(${user.userName}@${host.name})";
            # UTM module home-manager only
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.virtualization-utm
              ];
            };
          };
        };

        # The windows driver aspect
        provides.windows = {
          name = "development/virtualization/windows";
          # Install to os
          os = {...}: {
            imports = [
              inputs.self.modules.generic.virtualization-windows
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.virtualization-windows
            ];
          };
        };
      };
    };
  };

  # Enable libvirt in nixos
  flake.modules = {
    # Libvirt base setup
    nixos.virtualization-libvirt = {pkgs, ...}: {
      key = "virtualization-libvirt#nixos";
      config = {
        # Enable libvirt daemon
        virtualisation.libvirtd.enable = true;
        # Enable the frontend in nixos
        programs.virt-manager.enable = true;
        # Enable USB redirection
        virtualisation.spiceUSBRedirection.enable = true;
        # Install virtio drivers
        environment.systemPackages = with pkgs; [
          spice-gtk
        ];
      };
    };
    darwin.virtualization-libvirt = {...}: {
      key = "virtualization-libvirt#darwin";
      config = {
        # Install through brew; so runs as daemon (no nix-darwin module)
        homebrew.brews = [
          "libvirt"
        ];
      };
    };
    homeManager.virtualization-libvirt = {
      pkgs,
      lib,
      ...
    }: {
      key = "virtualization-libvirt#homeManager";
      config = lib.mkMerge [
        ( # Set virt-manager to auto-connect to system in linux
          lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
            dconf.settings = {
              "org/virt-manager/virt-manager/connections" = {
                autoconnect = ["qemu:///system"];
                uris = ["qemu:///system"];
              };
            };
          }
        )
        ( # Install virt-manager darwin userspace; in nixos it's from os
          lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
            home.packages = with pkgs; [
              virt-manager
            ];
          }
        )
      ];
    };

    # UTM for darwin
    homeManager.virtualization-utm = {pkgs, ...}: {
      key = "virtualization-utm#homeManager";
      config = {
        # UTM not available in linuxassertions =
        assertions = [
          {
            assertion = pkgs.stdenv.hostPlatform.isDarwin;
            message = "UTM is to be used only in MacOS";
          }
        ];
        # Install utm to darwin namespace
        home.packages = with pkgs; [
          utm
        ];
      };
    };

    # Driver packages for os
    generic.virtualization-windows = {pkgs, ...}: {
      key = "virtualization-windows#generic";
      config = {
        # Install virtio drivers
        environment.systemPackages = with pkgs; [
          virtio-win
        ];
      };
    };
    homeManager.virtualization-windows = {pkgs, ...}: {
      key = "virtualization-windows#homeManager";
      config = {
        # Install virtio drivers
        home.packages = with pkgs; [
          virtio-win
        ];
      };
    };
  };
}

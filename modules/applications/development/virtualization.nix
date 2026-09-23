# Virtualization setup
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    classes.virtualization.description = "Sets a user up for virtualization";
    schema = {
      host = {
        includes = [
          den.aspects.virtualization.policies.virtualization-host-dispatch
        ];
        imports = [
          ({config, ...}: {
            options = {
              virtualization = lib.mkOption {
                description = "Virtualization metadata on this host";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Whether to enable virtualization on this host";
                      default = false;
                      type = lib.types.bool;
                      apply = flag:
                        if (builtins.elem config.class ["nixos" "darwin"])
                        then flag
                        else false;
                    };
                    windows = lib.mkOption {
                      description = "Whether to install windows guest drivers as well";
                      default = true;
                      type = lib.types.bool;
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
          den.aspects.virtualization.policies.virtualization-user-dispatch
        ];
      };
    };

    aspects.virtualization = {
      # Policy for dispatching virtualization setup to host
      policies.virtualization-host-dispatch = {host, ...}:
        lib.optionals
        host.virtualization.enable
        (
          [
            (den.lib.policy.include den.aspects.virtualization)
          ]
          ++ (
            lib.optional
            host.virtualization.windows
            (den.lib.policy.include den.aspects.virtualization._.windows)
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
          host.virtualization.enable
          && (builtins.elem "virtualization" user.classes)
        )
        [
          (den.lib.policy.include den.aspects.virtualization._.user-setup)
        ];

      # Nixos module
      nixos = {...}: {
        imports = [
          inputs.self.modules.nixos.virtualization-settings
        ];
      };
      # The windows drivers
      provides.windows = {
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.virtualization-windows
          ];
        };
      };
      # User dispatch for interacting and virtualizing
      # No to-user; we don't want unconditional dispatch
      provides.user-setup = {
        host,
        user,
      }: {
        name = "virtualization(${user.userName}@${host.name})";
        homeManager = {...}: {
          imports = [
            inputs.self.modules.homeManager.virtualization-settings
          ];
        };
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
  };

  # Enable libvirt in nixos
  flake.modules.nixos.virtualization-settings = {pkgs, ...}: {
    key = "virtualization-settings#nixos";
    config = {
      # Setup libvirt and virt-manager
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;

      # Enable USB redirection
      virtualisation.spiceUSBRedirection.enable = true;

      # Install virtio drivers
      environment.systemPackages = with pkgs; [
        spice-gtk
      ];
    };
  };
  flake.modules.nixos.virtualization-windows = {pkgs, ...}: {
    key = "virtualization-windows#nixos";
    config = {
      # Install virtio drivers
      environment.systemPackages = with pkgs; [
        virtio-win
      ];
    };
  };
  flake.modules.homeManager.virtualization-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "virtualization-settings#homeManager";
    config = lib.mkMerge [
      (
        # Set virt-manager to auto-connect to system in linux
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = ["qemu:///system"];
              uris = ["qemu:///system"];
            };
          };
        }
      )
      (
        # Install UTM to darwin userspace
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          home.packages = with pkgs; [
            utm
          ];
        }
      )
    ];
  };
}

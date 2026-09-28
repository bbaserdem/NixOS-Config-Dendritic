# Nixos; configuring the boot bootloader; UEFI only
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    # Host schema additions for selecting bootloader behavior in nixos
    schema.host = {config, ...}: {
      options = {
        boot = lib.mkOption {
          description = "Bootloader info (NixOS only)";
          default =
            if config.class == "nixos"
            then {}
            else null;
          apply = value:
            if config.class == "nixos"
            then value
            else if (value != null)
            then
              throw ''
                Host ${config.name}'s boot must be null unless class is "nixos"
                ${config.name}.class is currently `${config.class}`
              ''
            else null;
          type = lib.types.nullOr (
            lib.types.submodule ({...}: {
              options = {
                configurationLimit = lib.mkOption {
                  description = "Number of entries to keep in the boot menu";
                  default = 10;
                  type = lib.types.int;
                };
                loader = lib.mkOption {
                  description = "Bootloader backend to enable.";
                  default = "grub";
                  type = lib.types.nullOr (lib.types.enum [
                    "systemd-boot"
                    "grub"
                  ]);
                };
                grub = lib.mkOption {
                  description = "GRUB options";
                  default = {};
                  type = lib.types.submodule ({...}: {
                    options = {
                      stylix = lib.mkOption {
                        description = "Whether to use stylix to theme grub";
                        default = true;
                        type = lib.types.bool;
                      };
                      flavor = lib.mkOption {
                        description = "Grub theme variant to use outside stylix";
                        default = "dark";
                        type = lib.types.enum [
                          "orange"
                          "white"
                          "dark"
                          "bigSur"
                        ];
                      };
                    };
                  });
                };
              };
            })
          );
        };
      };
    };

    aspects.system = {
      provides.nixos = {
        # Policy that enables the dispatch of boot loader type
        includes = [
          den.aspects.system._.nixos.policies.nixos-bootloader-dispatch
        ];
        policies.nixos-bootloader-dispatch = {host, ...}:
          lib.optionals
          (
            (host.class == "nixos")
            && (host.boot != null)
            && (host.boot.loader != null)
          )
          [
            (
              den.lib.policy.include
              den.aspects.system._.nixos._.bootloader
            )
            (
              den.lib.policy.include
              den.aspects.system._.nixos._.bootloader._.${host.boot.loader}
            )
          ];

        # Bootloader implementation base aspect
        provides.bootloader = {
          name = "system/nixos/bootloader";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-bootloader
            ];
          };

          # Grub implementation
          provides.grub = {host}: {
            name = "system/nixos/bootloader/grub(@${host.name})";
            # Nixos module enable for grub
            nixos = {
              options,
              pkgs,
              ...
            }: {
              imports = [
                inputs.self.modules.nixos.nixos-grub
              ];
              config = lib.mkMerge [
                {
                  # Host specific grub settings
                  boot.loader.grub.configurationLimit = host.boot.configurationLimit;
                }
                (
                  # If stylix is overriden, or unavailable, use config theme
                  lib.mkIf (!(
                    (host.boot.grub.stylix)
                    && (lib.hasAttrByPath ["stylix"] options)
                  )) {
                    boot.loader.grub.theme = pkgs.sleek-grub-theme.override {
                      withStyle = host.boot.grub.flavor;
                    };
                  }
                )
              ];
            };
            # Enable grub theming if required conditions are met
            stylix =
              lib.mkIf (
                (host.class == "nixos")
                && (host.boot.grub.stylix or false)
              ) {
                targets.grub = {
                  enable = true;
                  useWallpaper = true;
                };
              };
          };

          # Systemd-boot implementation
          provides.systemd-boot = {host}: {
            name = "system/nixos/bootloader/systemd-boot(@${host.name})";
            # Configure systemd-boot for nixos
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.nixos-systemd-boot
              ];
              config = {
                # Host specific systemd-boot settings
                boot.loader.systemd-boot = {
                  configurationLimit = host.boot.configurationLimit;
                };
              };
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules.nixos = {
    # Base bootloader
    nixos-bootloader = {...}: {
      key = "nixos-bootloader#nixos";
      config = {
        boot = {
          initrd.systemd.enable = true;
          loader = {
            efi = {
              canTouchEfiVariables = true;
              efiSysMountPoint = "/boot";
            };

            # Override defaults; needs to be done later!
            grub.enable = lib.mkDefault false;
            systemd-boot.enable = lib.mkDefault false;
          };
        };
      };
    };
    # Grub
    nixos-grub = {...}: {
      key = "nixos-grub#nixos";
      config = {
        # Grub settings
        boot.loader.grub = {
          enable = true;
          efiSupport = true;
          useOSProber = true;
          memtest86.enable = true;
          devices = ["nodev"];
        };
      };
    };
    # Systemd-boot
    nixos-systemd-boot = {...}: {
      key = "nixos-systemd-boot#nixos";
      config = {
        # Systemd-boot settings
        # Not currently used, but can switch to in the future
        boot.loader.systemd-boot = {
          enable = true;
          edk2-uefi-shell = {
            enable = true;
            sortKey = "y_edk2-uefi-shell";
          };
          memtest86 = {
            enable = true;
            sortKey = "z_memtest86";
          };
          netbootxyz = {
            enable = true;
            sortKey = "x_netbookxyz";
          };
        };
      };
    };
  };
}

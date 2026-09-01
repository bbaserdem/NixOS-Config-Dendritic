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
      includes = [
        den.aspects.system._.bootloader.policies.nixos-bootloader-dispatch
      ];

      # Bootloader implementations
      provides.bootloader = {
        # Policy that enables the dispatch of boot loader type
        policies.nixos-bootloader-dispatch = {host, ...}:
          if
            (
              (host.class == "nixos")
              && (host.boot != null)
              && (host.boot.loader != null)
            )
          then [
            (den.lib.policy.include den.aspects.system._.bootloader)
            (den.lib.policy.include den.aspects.system._.bootloader._.${host.boot.loader})
          ]
          else [];

        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.nixos-boot
          ];
        };

        # Grub implementation
        provides.grub = {host}: {
          # Nixos module enable for grub
          nixos = {
            options,
            pkgs,
            ...
          }: {
            config = lib.mkMerge [
              {
                # Grub settings
                boot.loader.grub = {
                  enable = true;
                  efiSupport = true;
                  useOSProber = true;
                  configurationLimit = host.boot.configurationLimit;
                  memtest86.enable = true;
                  devices = ["nodev"];
                };
              }
              (
                # If stylix is overriden, or unavailable, use the theme set by config
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
          # Configure systemd-boot for nixos
          nixos = {...}: {
            # Systemd-boot settings
            # Not used, but can switch to in the future
            boot.loader.systemd-boot = {
              enable = true;
              configurationLimit = host.boot.configurationLimit;
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
    };
  };

  flake.modules.nixos.nixos-boot = {...}: {
    # Main boot options
    boot = {
      initrd.systemd.enable = true;
      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };

        # Just override nixos defaults, we do our selection ourselves
        grub.enable = lib.mkDefault false;
        systemd-boot.enable = lib.mkDefault false;
      };
    };
  };

  # TODO; Remove these after den migration
  flake.modules.nixos.nixos-boot-local = {lib, ...}: {
    # Allow hosts to determine the bootloader to use
    options = {
      local.boot = {
        loader = lib.mkOption {
          type = lib.types.enum [
            "systemd-boot"
            "grub"
          ];
          default = "grub";
          description = "Bootloader backend to enable for the NixOS host.";
        };
        grub = {
          stylix = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to use stylix to theme grub";
          };
          flavor = lib.mkOption {
            type = lib.types.enum [
              "orange"
              "white"
              "dark"
              "bigSur"
            ];
            default = "dark";
            description = "Grub theme variant to use outside stylix";
          };
        };
      };
    };
  };

  flake.modules.nixos.nixos-boot-grub = {
    config,
    lib,
    options,
    pkgs,
    ...
  }: let
    configurationLimit = 10;
  in {
    config = lib.mkIf (config.local.boot.loader == "grub") (
      lib.mkMerge [
        {
          # Grub settings
          boot.loader.grub = {
            inherit configurationLimit;
            enable = true;
            efiSupport = true;
            useOSProber = true;
            memtest86.enable = true;
            devices = ["nodev"];
          };
        }
        (
          # If stylix is overriden, or unavailable, use sleek-grub-theme
          lib.mkIf (!(
            (config.local.boot.grub.stylix)
            && (lib.hasAttrByPath ["stylix"] options)
          )) {
            boot.loader.grub.theme = pkgs.sleek-grub-theme.override {
              withStyle = config.local.boot.grub.flavor;
            };
          }
        )
      ]
    );
  };

  flake.modules.nixos.nixos-boot-systemd = {
    config,
    lib,
    ...
  }: let
    configurationLimit = 10;
  in {
    config = lib.mkIf (config.local.boot.loader == "systemd-boot") {
      # Systemd-boot settings
      # Not used, but can switch to in the future
      boot.loader.systemd-boot = {
        enable = true;
        inherit configurationLimit;
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

  # Stylix theming of grub?
  flake.modules.nixos.stylix = {...}: {
    stylix.targets.grub = {
      enable = true;
      useWallpaper = true;
    };
  };
}

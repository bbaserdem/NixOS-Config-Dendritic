# Nixos; configuring the boot bootloader; UEFI only
{...}: {
  flake.modules.nixos = {
    nixos = {
      config,
      lib,
      options,
      pkgs,
      ...
    }: {
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

      config = lib.mkMerge [
        {
          # Main boot options
          boot = {
            initrd.systemd.enable = true;
            loader = {
              efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = "/boot";
              };
            };
          };
        }
        (
          lib.mkIf (config.local.boot.loader == "grub") (
            lib.mkMerge [
              {
                # Grub settings
                boot.loader.grub = {
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
          )
        )
        (
          lib.mkIf (config.local.boot.loader == "systemd-boot") {
            # Systemd-boot settings
            # Not used, but can switch to in the future
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
              configurationLimit = 10;
            };
          }
        )
      ];
    };

    # Stylix theming of grub?
    stylix = {...}: {
      stylix.targets.grub = {
        enable = true;
        useWallpaper = true;
      };
    };
  };
}

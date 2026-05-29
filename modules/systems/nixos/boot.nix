# Nixos; configuring the boot bootloader
{...}: {
  flake.modules.nixos = {
    nixos = {...}: {
      boot = {
        initrd.systemd.enable = true;
        loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };
          grub = {
            enable = true;
            efiSupport = true;
            useOSProber = true;
            memtest86.enable = true;
          };
        };
      };
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

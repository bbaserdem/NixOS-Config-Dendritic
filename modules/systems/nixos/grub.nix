# Nixos; configure grub as the bootloader
{...}: {
  flake.modules.nixos = {
    nixos = {...}: {
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        useOSProbel = true;
        memtest86.enable = true;
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

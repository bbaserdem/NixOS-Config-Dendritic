# SSH common config
{...}: {
  flake.modules = {
    # Generic module for both contexts
    generic.yubikey = {pkgs, ...}: {
      # Install packages to userspace
      environment.systemPackages = with pkgs; [
        yubikey-manager
      ];
    };

    # NixOS Yubikey integration
    nixos.yubikey = {pkgs, ...}: {
      services = {
        # Enable smartcard daemon
        pcscd.enable = true;
        # Udev rules for non-root access
        udev.packages = with pkgs; [
          yubikey-personalization
        ];
      };
      # Enable yubikey hardware
      hardware.gpgSmartcards.enable = true;
    };
  };
}

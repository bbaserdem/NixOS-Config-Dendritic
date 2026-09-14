# Yubikey setup
{...}: {
  # Modules
  flake.modules = {
    # Generic module for both nixos and darwin
    generic.yubikey-settings = {pkgs, ...}: {
      key = "yubikey-settings#generic";
      config = {
        # Install packages to userspace
        environment.systemPackages = with pkgs; [
          yubikey-manager
        ];
      };
    };

    # NixOS Yubikey integration
    nixos.yubikey-settings = {pkgs, ...}: {
      key = "yubikey-settings#nixos";
      config = {
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

    # Home manager
    homeManager.yubikey-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "yubikey-settings#homeManager";
      config = lib.mkMerge [
        (
          # In linux, internal ccid conflicts with pcscd; (auto in darwin)
          lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
            programs.gpg.scdaemonSettings.disable-ccid = true;
          }
        )
      ];
    };
  };
}

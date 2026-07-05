# Nixos; load sane default kernel modules for all hardware
{...}: {
  # NixOS hardware configs
  flake-file.inputs = {
    hardware.url = "github:nixos/nixos-hardware";
  };

  # Common hardware configuration to dispatch
  flake.modules.nixos.nixos = {pkgs, ...}: {
    config = {
      hardware.enableRedistributableFirmware = true;

      # Enable udev
      services.udev = {
        enable = true;
      };

      # Hardware utilities
      environment.systemPackages = with pkgs; [
        pciutils
      ];
    };
  };
}

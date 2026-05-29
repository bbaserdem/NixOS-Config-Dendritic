# Nixos; load sane default kernel modules for all hardware
{...}: {
  # NixOS hardware configs
  flake-file.inputs = {
    hardware.url = "github:nixos/nixos-hardware";
  };

  # Common hardware configuration to dispatch
  flake.modules.nixos.nixos = {modulesPath, ...}: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    config = {
      hardware.enableRedistributableFirmware = true;
    };
  };
}

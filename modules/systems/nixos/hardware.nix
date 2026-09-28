# Nixos hardware flake, and shared settings
{
  inputs,
  den,
  ...
}: {
  # NixOS hardware module flake
  flake-file.inputs = {
    hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Aspect management
  den = {
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.hardware
        ];
        provides.hardware = {
          name = "system/nixos/hardware";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-hardware
            ];
          };
        };
      };
    };
  };

  # Common hardware configuration to dispatch
  flake.modules.nixos.nixos-hardware = {pkgs, ...}: {
    key = "nixos-hardware#nixos";
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

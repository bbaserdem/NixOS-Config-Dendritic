# Nixos; firmware update daemon
{...}: {
  # Common firmware update daemon to enable on systems
  flake.modules.nixos.nixos-firmware = {pkgs, ...}: {
    key = "nixos-firmware#nixos";
    config = {
      services.fwupd = {
        enable = true;
      };
    };
  };
}

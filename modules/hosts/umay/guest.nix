# Umay vm-guest related configuration
{...}: {
  flake.modules.nixos.umay = {modulesPath, ...}: {
    # Import nixos qemu guest module from nixpkgs
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    # Guest services
    services = {
      qemuGuest.enable = true;
      spice-vdagentd.enable = true;
    };
  };
}

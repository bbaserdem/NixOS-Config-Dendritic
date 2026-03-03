# Guest related configuration for nixos guest vms
{...}: {
  flake.modules.nixos = {
    vm = {modulesPath, ...}: {
      # Import nixos qemu guest module from nixpkgs
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      # Guest services integration for different tooling
      services = {
        qemuGuest.enable = true;
        spice-vdagentd.enable = true;
        spice-webdavd.enable = true;
      };
    };
  };
}

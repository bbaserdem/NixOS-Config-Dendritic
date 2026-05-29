# Su-ana firmware confgig
{...}: {
  flake.modules.nixos.yel-ana = {pkgs, ...}: {
    # Microcode update
    hardware.cpu.amd.updateMicrocode = true;

    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "uas"
        "sd_mod"
      ];
      kernel.sysctl."vm.swappiness" = 0;
      kernelModules = [
        "kvm-amd"
      ];

      # Use latest kernel
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}

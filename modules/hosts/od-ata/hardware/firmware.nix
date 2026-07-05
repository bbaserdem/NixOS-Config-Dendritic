# Od-Ata firmware configuration
{...}: {
  flake.modules.nixos.od-ata = {pkgs, ...}: {
    config = {
      # System behavior
      boot = {
        # Avoid swap if we can
        kernel.sysctl."vm.swappiness" = 0;
        # Virtualization kernel module, for cross comp
        kernelModules = ["kvm-amd"];
      };

      # Use mainline kernel
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}

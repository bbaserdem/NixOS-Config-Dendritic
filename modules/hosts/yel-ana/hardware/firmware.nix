# Su-ana firmware configuration
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {pkgs, ...}: {
    # Load chaotic modules for cachyos kernel
    imports =
      (with inputs.chaotic.nixosModules; [
        nyx-cache
        nyx-overlay
        nyx-registry
      ])
      ++ (with inputs.self.modules.nixos; [
        nixos-vulkan
      ]);

    config = {
      # System behavior
      boot = {
        # Avoid swap if we can
        kernel.sysctl."vm.swappiness" = 0;
        # Virtualization kernel module, for cross comp
        kernelModules = ["kvm-amd"];
        kernelParams = ["amd_pstate=active"];
      };

      # Use cachyos kernel
      boot.kernelPackages = pkgs.linuxPackages_cachyos-lto-znver4;

      # Additional kernels to test
      specialisation."Fallback Kernel" = {
        configuration = {
          pkgs,
          lib,
          ...
        }: {
          boot.kernelPackages = lib.mkOverride 900 pkgs.linuxPackages_latest;
        };
      };
    };
  };
}

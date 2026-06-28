# Su-ana firmware configuration
{inputs, ...}: {
  flake.modules.nixos.yel-ana = {
    pkgs,
    lib,
    ...
  }: {
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
      };

      # Use latest kernel by default
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Additional kernels to test
      specialisation =
        [
          "zen"
          "xanmod_latest"
          "cachyos-lto-znver4"
        ]
        |> map (kernel:
          lib.nameValuePair "kernel-${kernel}" {
            configuration = {
              pkgs,
              lib,
              ...
            }: {
              boot.kernelPackages = lib.mkForce pkgs.${"linuxPackages_${kernel}"};
            };
          })
        |> builtins.listToAttrs;
    };
  };
}

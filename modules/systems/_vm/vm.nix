# VM modules for nixos guest configurations
# These load the generic vm config for both amd64 and arm architectures
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.system = {
      provides.virtual-machine = {
        # Policy dispatch for proper subtype
        policies.vm-subtype-dispatch = {host, ...}:
          if (host.system == "x86_64-linux")
          then [(den.lib.policy.include den.aspects.system._.virtual-machine._.vm-amd)]
          else if (host.system == "aarch64-linux")
          then [(den.lib.policy.include den.aspects.system._.virtual-machine._.vm-arm)]
          else [];
        includes = [
          den.aspects.system._.virtual-machine.policies.vm-subtype-dispatch
        ];
        excludes = [
          den.aspects.system._.bootloader.policies.nixos-bootloader-dispatch
        ];

        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.virtual-machine
          ];
        };

        provides.vm-arm = {
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.virtual-machine-arm
            ];
          };
        };
        provides.vm-amd = {
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.virtual-machine-amd
            ];
          };
        };
      };
    };
  };

  flake.modules.nixos = {
    vm-arm = {...}: {
      imports = [
        inputs.self.modules.nixos.virtual-machine
        inputs.self.modules.nixos.virtual-machine-arm
      ];
    };
    vm-amd = {...}: {
      imports = [
        inputs.self.modules.nixos.virtual-machine
        inputs.self.modules.nixos.virtual-machine-amd
      ];
    };
  };
}

# VM modules for nixos guest configurations
# These load the generic vm config for both amd64 and arm architectures
{inputs, ...}: {
  flake.modules.nixos = {
    vm-arm = {...}: {
      imports = [
        inputs.self.modules.nixos.vm
      ];
    };
    vm-amd = {...}: {
      imports = [
        inputs.self.modules.nixos.vm
      ];
    };
  };
}

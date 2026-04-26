# General systems boilerplate
{inputs, ...}: {
  config = {
    flake = {
      # Initialize default modules for system management
      modules = {
        generic.default = {...}: {};
        nixos.default = {...}: {imports = [inputs.self.modules.generic.default];};
        darwin.default = {...}: {imports = [inputs.self.modules.generic.default];};
        homeManager.default = {...}: {imports = [inputs.self.modules.generic.default];};
      };
    };
  };
}

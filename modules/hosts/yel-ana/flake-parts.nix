# Flake-parts config for su-ana
{inputs, ...}: {
  flake = {
    darwinConfigurations = inputs.self.lib.mkDarwin {
      system = "aarch64-darwin";
      name = "su-ana";
      description = "Su Ana: Batuhan's MBP";
    };
  };
}

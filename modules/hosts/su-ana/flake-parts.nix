# Flake-parts config for su-ana
{config, ...}: {
  flake = {
    darwinConfigurations = config.factory.mkDarwin {
      system = "aarch64-darwin";
      name = "su-ana";
      description = "Su Ana: Batuhan's MBP";
    };
  };
}

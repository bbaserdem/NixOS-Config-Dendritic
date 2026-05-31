# Flake-parts config for yel-ana
{config, ...}: {
  flake = {
    nixosConfigurations = config.factory.mkNixos {
      system = "x86_64-linux";
      name = "yel-ana";
      description = "Yel Ana: Batuhan's Laptop";
    };
  };
}

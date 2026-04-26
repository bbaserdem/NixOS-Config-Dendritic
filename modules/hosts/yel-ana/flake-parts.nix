# Flake-parts config for yel-ana
{inputs, ...}: {
  flake = {
    nixosConfigurations = inputs.self.lib.mkNixos {
      system = "x86_64-linux";
      name = "yel-ana";
      description = "Yel Ana: Batuhan's Laptop";
    };
  };
}

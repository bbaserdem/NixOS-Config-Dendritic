# Flake-parts config for kayra
{config, ...}: {
  flake = {
    nixosConfigurations = config.factory.mkNixos {
      system = "x86_64-linux";
      name = "kayra";
      description = "Kayra: Live NixOS ISO";
    };

    # Output us as a package
    packages."x86_64-linux".kayra = config.flake.nixosConfigurations.kayra.config.system.build.isoImage;
  };
}

# Flake-parts config for od-ata
{config, ...}: {
  flake = {
    nixosConfigurations = config.factory.mkNixos {
      system = "x86_64-linux";
      name = "od-ata";
      description = "Od Ata: Home server";
    };
  };
}

# Od-Ata syncthing config
{inputs, ...}: {
  localConfig.syncthing.hosts."od-ata".id = "SURUPHR-XMRJVSZ-4E2BL6S-KEAX4C4-LOMYYI4-KSPWQEZ-75ZQDS4-O4EIBA6";

  flake.modules.nixos.od-ata = {...}: {
    imports = with inputs.self.modules.nixos; [
      syncthing
    ];
  };
}

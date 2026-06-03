# Su-ana syncthing config
{inputs, ...}: {
  localConfig.syncthing.hosts."yel-ana".id = "RBX3SWP-PGCGSXH-UKVCH74-ZM55W36-3M467UU-O64ZBXT-CTU5WMN-LSAJ5QR";

  flake.modules.nixos.yel-ana = {...}: {
    imports = with inputs.self.modules.nixos; [
      syncthing
    ];
  };
}

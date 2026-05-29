# Su-ana syncthing config
{inputs, ...}: {
  # TODO; Generate secrets/public-id
  localConfig.syncthing.hosts."su-ana".id = "AWRTUF4-MXSTBEU-C6MBBL6-3OXH3AM-OW3SR4K-CQKFXVA-GXHB3YU-X3EBEAH";

  flake.modules.darwin.su-ana = {...}: {
    imports = with inputs.self.modules.darwin; [
      syncthing
      caddy
    ];
  };
}

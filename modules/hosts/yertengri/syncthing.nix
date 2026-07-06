# Yertengr syncthing config
{inputs, ...}: {
  localConfig.syncthing.hosts."yertengri".id = "OGURLTB-BBT3MMT-CCK23PS-FT76672-YMWVY4T-6AR7LIO-22O6VN2-GJB3DAF";

  flake.modules.nixos.yertengri = {...}: {
    imports = with inputs.self.modules.nixos; [
      syncthing
    ];
  };
}

# Configuring the VPN provider to the container
{
  inputs,
  config,
  ...
}: let
  torrentCfg = config.localConfig.torrent;
in {
  flake.modules.nixos.service-torrent = {
    lib,
    options,
    config,
    ...
  }: {
    config = lib.mkMerge [
      (
        # Load sops secrets for the VPN
        lib.mkIf (lib.hasAttrByPath ["sops"] options) (
          let
            sopsCfg = {
              sopsFile = inputs.self + /secrets/vpn.yaml;
              owner = "root";
              group = "root";
              mode = "0400";
              restartUnits = ["container@${torrentCfg.name}.service"];
            };
          in (
            lib.mkMerge [
              {
                # Dispatch the wireguard config file to the container
                containers."${torrentCfg.name}".bindMounts = {
                  "/run/secrets/${torrentCfg.name}-wireguard.conf" = {
                    hostPath = config.sops.templates."${torrentCfg.name}-wireguard.conf".path;
                    mountPoint = "/run/secrets/wireguard.conf";
                    isReadOnly = true;
                  };
                };
              }
              (
                # Just a stub; needs to produce an actual wireguard config
                lib.mkIf (torrentCfg.vpn.interface == "mullvad") {
                  sops = {
                    secrets = {
                      "mullvad/key" = sopsCfg;
                    };
                    templates."${torrentCfg.name}-wireguard.conf" = {
                      mode = "0400";
                      content = ''
                        key=${config.sops.placeholder."mullvad/key"};
                      '';
                    };
                  };
                }
              )
            ]
          )
        )
      )
      (
        # Setup mullvad in the container
        lib.mkIf (torrentCfg.vpn.interface == "mullvad") {
        }
      )
    ];
  };
}

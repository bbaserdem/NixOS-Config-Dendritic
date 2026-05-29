# Syncthing hosts configuration
# Create syncthing device configuration from global host topology
{config, ...}: let
  cfg = config.localConfig.syncthing;
in {
  config.flake.modules = {
    generic.syncthing = {
      config,
      lib,
      options,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["networking" "hostName"] options) (let
        # Only emit valid remote devices.
        #
        # Empty IDs are useful while bootstrapping a host, but Syncthing device
        # definitions need a real ID.
      in {
        services.syncthing.settings.devices =
          cfg.hosts
          |> lib.filterAttrs (name: host: ((host.id != "") && (name != (config.networking.hostName ? null))))
          |> lib.mapAttrs (name: host: {
            id = host.id;
          });
      });
    };
  };
}

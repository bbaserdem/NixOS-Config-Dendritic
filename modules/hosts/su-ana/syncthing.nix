# Su-ana syncthing config
{inputs, ...}: {
  flake.modules = {
    # Enable syncthing for this computer
    darwin.su-ana = {...}: {
      imports = [
        inputs.self.modules.darwin.syncthing
      ];
    };
    # Global configuration
    generic.syncthing = {config, ...}: {
      config = {
        services.syncthing.settings.devices."${config.networking.hostName}" = {
          name = "Su Ana";
          id = "AWRTUF4-MXSTBEU-C6MBBL6-3OXH3AM-OW3SR4K-CQKFXVA-GXHB3YU-X3EBEAH";
          autoAcceptFolders = false;
        };
      };
    };
  };
}

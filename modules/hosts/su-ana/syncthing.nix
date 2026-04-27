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
    generic.syncthing = {lib, ...}: {
      services.syncthing.settings = {
        # Register our computer with the syncthing module
        devices.su-ana = {
          name = "Su Ana";
          id = "AWRTUF4-MXSTBEU-C6MBBL6-3OXH3AM-OW3SR4K-CQKFXVA-GXHB3YU-X3EBEAH";
          autoAcceptFolders = false;
        };
        # Enable folders that we want in this computer
        folders = {
          wolframite-music = {
            enable = lib.mkDefault true;
            devices = [
              "su-ana"
            ];
          };
          wolframite-videos = {
            enable = lib.mkDefault true;
            devices = [
              "su-ana"
            ];
          };
        };
      };
    };
  };
}

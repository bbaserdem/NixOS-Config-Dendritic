# Syncthing; flake-parts
{inputs, ...}: {
  flake.modules = {
    # Syncthing setup

    # NixOS module; pull in generic module
    nixos.syncthing = {...}: {
      # Import module
      imports = [
        inputs.self.modules.generic.syncthing
      ];
    };

    # Darwin module; only enable syncthing for the "mainUser"
    # If system.mainUser is not set, WONT DISPATCH
    darwin.syncthing = {
      lib,
      options,
      config,
      ...
    }: {
      config = lib.mkIf (lib.hasAttrByPath ["system" "mainUser"] options) {
        home-manager.users = lib.mkIf (config.system.mainUser != null) {
          "${config.system.mainUser}".imports = [
            # Enable syncthing for this specific user
            inputs.self.modules.generic.syncthing
            inputs.self.modules.homeManager.syncthing
          ];
        };
      };
    };
  };
}

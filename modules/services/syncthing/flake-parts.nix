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
      config = lib.optionalAttrs (lib.hasAttrByPath ["local" "mainUser"] options) {
        home-manager.users = lib.mkIf (config.local.mainUser != null) {
          "${config.local.mainUser}".imports = [
            # Enable syncthing for this specific user
            inputs.self.modules.generic.syncthing
            inputs.self.modules.homeManager.syncthing
          ];
        };
      };
    };
  };
}

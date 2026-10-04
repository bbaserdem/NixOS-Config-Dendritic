# HomeManager: standalone entry module
{config, ...}: {
  # Den
  den = {
  };

  # Modules
  flake.modules.homeManager.hm-defaults = {lib, ...}: {
    key = "hm-defaults#homeManager";
    config = {
      # Our default state version for using home-manager
      home.stateVersion = lib.mkOverride 110 config.nixpkgs.version;
    };
  };
}

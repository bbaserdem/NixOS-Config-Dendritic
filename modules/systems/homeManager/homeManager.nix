# HomeManager: standalone entry module
{
  inputs,
  config,
  ...
}: {
  # Den
  # TODO: Make this less bespoke
  den = {
    aspects = {
      system = {host}: {
        homeManager = {lib, ...}: {
          imports =
            if (host.class == "homeManager")
            then
              (with inputs.self.modules.homeManager; [
                hm-networking
              ])
            else [];
          # Redundant check
          config = {
            home.stateVersion = lib.mkDefault config.nixpkgs.version;
          };
        };
      };
    };
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

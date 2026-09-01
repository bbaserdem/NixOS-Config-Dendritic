# Configuring standalone home manager systems
{
  inputs,
  config,
  ...
}: {
  den.aspects = {
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
          home.stateVersion = lib.mkDefault config.localConfig.nixVersion;
        };
      };
    };
  };

  # TODO: delete this after den migration
  flake.modules.homeManager.hm = {...}: {
    imports = with inputs.self.modules.homeManager; [
      hm-networking
    ];
  };
}

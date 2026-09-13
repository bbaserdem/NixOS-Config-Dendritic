# Enabling beets
# TODO: Remove after den migration
{inputs, ...}: {
  flake.modules.homeManager.beets = {...}: {
    imports = [
      inputs.self.modules.homeManager.beets-settings
    ];
  };
}

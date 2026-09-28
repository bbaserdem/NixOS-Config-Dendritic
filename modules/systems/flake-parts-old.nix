# General systems boilerplate
# TODO: Delete after den migration
{
  config,
  lib,
  ...
}: {
  config = {
    flake = {
      modules = lib.foldl lib.recursiveUpdate {} [
        (config.factory.inclusionModules "nix")
        (config.factory.inclusionModules "secrets")
        (config.factory.inclusionModules "stylix")
      ];
    };
  };
}

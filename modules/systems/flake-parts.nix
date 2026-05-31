# General systems boilerplate
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

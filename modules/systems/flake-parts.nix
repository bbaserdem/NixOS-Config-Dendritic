# General systems boilerplate
{
  inputs,
  lib,
  ...
}: {
  config = {
    flake = {
      modules = lib.foldl lib.recursiveUpdate {} [
        (inputs.self.factory.inclusionModules "nix")
        (inputs.self.factory.inclusionModules "secrets")
      ];
    };
  };
}

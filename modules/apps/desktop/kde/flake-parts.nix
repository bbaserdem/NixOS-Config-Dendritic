# Flake parts init modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factory modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "kde")
  ];
}

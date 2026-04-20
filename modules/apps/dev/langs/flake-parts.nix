# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "node")
    (inputs.self.factory.inclusionModules "python")
    (inputs.self.factory.inclusionModules "lean")
  ];
}

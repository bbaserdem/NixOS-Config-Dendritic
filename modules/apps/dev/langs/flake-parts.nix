# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "node")
    (config.factory.inclusionModules "python")
    (config.factory.inclusionModules "lean")
  ];
}

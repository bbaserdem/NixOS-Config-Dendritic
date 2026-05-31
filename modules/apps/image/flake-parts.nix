# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "image")
    (config.factory.inclusionModules "blender")
    (config.factory.inclusionModules "gimp")
  ];
}

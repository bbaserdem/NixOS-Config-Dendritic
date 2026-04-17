# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "image")
    (inputs.self.factory.inclusionModules "blender")
    (inputs.self.factory.inclusionModules "gimp")
  ];
}

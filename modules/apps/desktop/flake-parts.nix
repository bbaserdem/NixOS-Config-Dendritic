# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "fonts")
    (inputs.self.factory.inclusionModules "kdeconnect")
    (inputs.self.factory.inclusionModules "keyboard")
    (inputs.self.factory.inclusionModules "language")
    (inputs.self.factory.inclusionModules "stylix")
  ];
}

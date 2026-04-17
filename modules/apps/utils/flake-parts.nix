# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "archives")
    (inputs.self.factory.inclusionModules "btop")
    (inputs.self.factory.inclusionModules "mangohud")
    (inputs.self.factory.inclusionModules "mariadb")
    (inputs.self.factory.inclusionModules "tools")
  ];
}

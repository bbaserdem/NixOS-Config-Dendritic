# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "android")
    (inputs.self.factory.inclusionModules "bluetooth")
    (inputs.self.factory.inclusionModules "firmware")
    (inputs.self.factory.inclusionModules "fingerprint")
    (inputs.self.factory.inclusionModules "qmk")
    (inputs.self.factory.inclusionModules "power")
    (inputs.self.factory.inclusionModules "printing")
    (inputs.self.factory.inclusionModules "rasdaemon")
    (inputs.self.factory.inclusionModules "sound")
    (inputs.self.factory.inclusionModules "udisks")
  ];
}

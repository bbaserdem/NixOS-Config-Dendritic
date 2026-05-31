# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "android")
    (config.factory.inclusionModules "bluetooth")
    (config.factory.inclusionModules "firmware")
    (config.factory.inclusionModules "fingerprint")
    (config.factory.inclusionModules "qmk")
    (config.factory.inclusionModules "power")
    (config.factory.inclusionModules "printing")
    (config.factory.inclusionModules "rasdaemon")
    (config.factory.inclusionModules "sound")
    (config.factory.inclusionModules "udisks")
  ];
}

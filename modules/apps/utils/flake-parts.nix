# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "archives")
    (config.factory.inclusionModules "btop")
    (config.factory.inclusionModules "mangohud")
    (config.factory.inclusionModules "mariadb")
    (config.factory.inclusionModules "tools")
  ];
}

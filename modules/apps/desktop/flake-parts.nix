# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "fonts")
    (config.factory.inclusionModules "gtk")
    (config.factory.inclusionModules "kdeconnect")
    (config.factory.inclusionModules "keyboard")
    (config.factory.inclusionModules "language")
    (config.factory.inclusionModules "geoclue")
    (config.factory.inclusionModules "qt")
    (config.factory.inclusionModules "xdg")
    (config.factory.inclusionModules "waylandShell")
  ];
}

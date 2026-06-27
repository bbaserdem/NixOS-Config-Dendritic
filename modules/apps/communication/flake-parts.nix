# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "comms")
    (config.factory.inclusionModules "chrome")
    (config.factory.inclusionModules "chromium")
    (config.factory.inclusionModules "firefox")
    (config.factory.inclusionModules "discord")
    (config.factory.inclusionModules "remmina")
    (config.factory.inclusionModules "zoom")
    (config.factory.inclusionModules "slack")
    (config.factory.inclusionModules "signal")
  ];
}

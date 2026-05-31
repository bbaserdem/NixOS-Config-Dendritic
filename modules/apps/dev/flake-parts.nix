# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "vcs")
    (config.factory.inclusionModules "docker")
    (config.factory.inclusionModules "virtualization")
    (config.factory.inclusionModules "ai")
    (config.factory.inclusionModules "ghostty")
    (config.factory.inclusionModules "kitty")
  ];
}

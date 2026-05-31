# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "docs")
    (config.factory.inclusionModules "foliate")
    (config.factory.inclusionModules "newsboat")
    (config.factory.inclusionModules "obsidian")
    (config.factory.inclusionModules "office")
    (config.factory.inclusionModules "zathura")
  ];
}

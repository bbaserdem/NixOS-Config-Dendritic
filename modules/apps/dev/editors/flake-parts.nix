# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "nvim")
    (config.factory.inclusionModules "neovide")
    (config.factory.inclusionModules "vscodium")
    (config.factory.inclusionModules "zed")
  ];
}

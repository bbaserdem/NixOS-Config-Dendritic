# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "audio")
    (config.factory.inclusionModules "beets")
    (config.factory.inclusionModules "mpd")
    (config.factory.inclusionModules "midi")
  ];
}

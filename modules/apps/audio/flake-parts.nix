# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "audio")
    (inputs.self.factory.inclusionModules "beets")
    (inputs.self.factory.inclusionModules "mpd")
    (inputs.self.factory.inclusionModules "midi")
  ];
}

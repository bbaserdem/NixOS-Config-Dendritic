# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "avahi")
    (inputs.self.factory.inclusionModules "geoclue")
    (inputs.self.factory.inclusionModules "networking")
    (inputs.self.factory.inclusionModules "networkmanager")
    (inputs.self.factory.inclusionModules "remmina")
  ];
}

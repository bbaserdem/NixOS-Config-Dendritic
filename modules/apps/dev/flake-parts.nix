# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "vcs")
    (inputs.self.factory.inclusionModules "docker")
    (inputs.self.factory.inclusionModules "virtualization")
    (inputs.self.factory.inclusionModules "ai")
    (inputs.self.factory.inclusionModules "ghostty")
    (inputs.self.factory.inclusionModules "kitty")
  ];
}

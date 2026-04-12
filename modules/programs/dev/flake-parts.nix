# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "vcs")
    (inputs.self.factory.inclusionModules "shell")
    (inputs.self.factory.inclusionModules "docker")
    (inputs.self.factory.inclusionModules "virtualization")
    (inputs.self.factory.inclusionModules "editor")
    (inputs.self.factory.inclusionModules "node")
    (inputs.self.factory.inclusionModules "python")
    (inputs.self.factory.inclusionModules "ai")
  ];
}

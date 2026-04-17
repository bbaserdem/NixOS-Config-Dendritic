# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "docs")
    (inputs.self.factory.inclusionModules "foliate")
    (inputs.self.factory.inclusionModules "newsboat")
    (inputs.self.factory.inclusionModules "obsidian")
    (inputs.self.factory.inclusionModules "office")
    (inputs.self.factory.inclusionModules "zathura")
  ];
}

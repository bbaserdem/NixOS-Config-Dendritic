# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "nvim")
    (inputs.self.factory.inclusionModules "neovide")
    (inputs.self.factory.inclusionModules "vscode")
    (inputs.self.factory.inclusionModules "zed")
  ];
}

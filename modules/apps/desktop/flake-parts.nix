# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "fonts")
    (inputs.self.factory.inclusionModules "gnome")
    (inputs.self.factory.inclusionModules "gtk")
    (inputs.self.factory.inclusionModules "kdeconnect")
    (inputs.self.factory.inclusionModules "keyboard")
    (inputs.self.factory.inclusionModules "language")
    (inputs.self.factory.inclusionModules "plasma")
    (inputs.self.factory.inclusionModules "qt")
    (inputs.self.factory.inclusionModules "stylix")
    (inputs.self.factory.inclusionModules "xdg")
  ];
}

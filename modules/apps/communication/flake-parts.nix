# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "comms")
    (inputs.self.factory.inclusionModules "chrome")
    (inputs.self.factory.inclusionModules "chromium")
    (inputs.self.factory.inclusionModules "firefox")
    (inputs.self.factory.inclusionModules "discord")
    (inputs.self.factory.inclusionModules "remmina")
  ];
}

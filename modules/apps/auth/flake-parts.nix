# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "gpg")
    (inputs.self.factory.inclusionModules "keepassxc")
    (inputs.self.factory.inclusionModules "pass")
    (inputs.self.factory.inclusionModules "polkit")
    (inputs.self.factory.inclusionModules "ssh")
    (inputs.self.factory.inclusionModules "yubikey")
  ];
}

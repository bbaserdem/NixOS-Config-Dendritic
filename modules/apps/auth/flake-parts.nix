# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "gpg")
    (config.factory.inclusionModules "keepassxc")
    (config.factory.inclusionModules "pass")
    (config.factory.inclusionModules "polkit")
    (config.factory.inclusionModules "ssh")
    (config.factory.inclusionModules "yubikey")
  ];
}

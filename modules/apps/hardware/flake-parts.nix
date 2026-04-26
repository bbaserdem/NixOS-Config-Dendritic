# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "bluetooth")
    (inputs.self.factory.inclusionModules "firmware")
    (inputs.self.factory.inclusionModules "fingerprint")
    (inputs.self.factory.inclusionModules "filesystems")
    (inputs.self.factory.inclusionModules "qmk")
    (inputs.self.factory.inclusionModules "powertop")
    (inputs.self.factory.inclusionModules "printing")
    (inputs.self.factory.inclusionModules "rasdaemon")
    (inputs.self.factory.inclusionModules "sound")
    (inputs.self.factory.inclusionModules "tuned")
    (inputs.self.factory.inclusionModules "udev")
    (inputs.self.factory.inclusionModules "udisks")
    (inputs.self.factory.inclusionModules "upower")
  ];
}

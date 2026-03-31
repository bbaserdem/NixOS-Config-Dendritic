# Flake partsq inif modules
{inputs, ...}: {
  # Collect factoried modules
  flake.modules =
    {}
    // (inputs.self.factory.inclusionModules "communication")
    // (inputs.self.factory.inclusionModules "discord")
    // (inputs.self.factory.inclusionModules "firefox")
    // (inputs.self.factory.inclusionModules "gaming");
}

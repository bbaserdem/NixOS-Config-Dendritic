# Flake partsq inif modules
{inputs, ...}: {
  # Collect factoried modules
  flake.modules =
    {}
    // (inputs.self.factory.inclusionModules "ghostty")
    // (inputs.self.factory.inclusionModules "kitty");
}

# Flake partsq inif modules
{inputs, ...}: {
  # Collect factoried modules
  flake.modules =
    {}
    // (inputs.self.factory.inclusionModules "audio")
    // (inputs.self.factory.inclusionModules "beets")
    // (inputs.self.factory.inclusionModules "mpd")
    // (inputs.self.factory.inclusionModules "midi");
}

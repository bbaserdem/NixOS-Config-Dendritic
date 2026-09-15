# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "ai")
    (config.factory.inclusionModules "ai-claude")
    (config.factory.inclusionModules "ai-chatgpt")
    (config.factory.inclusionModules "ai-codegraph")
    (config.factory.inclusionModules "ai-codex")
    (config.factory.inclusionModules "ai-opencode")
    (config.factory.inclusionModules "ai-pi")
    (config.factory.inclusionModules "ai-droid")
    (config.factory.inclusionModules "ai-forgecode")
    (config.factory.inclusionModules "ai-sidepulse")
  ];
}

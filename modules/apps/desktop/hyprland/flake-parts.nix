# Flake parts init modules
{
  config,
  lib,
  ...
}: {
  # Collect factory modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "hyprland")
  ];
}

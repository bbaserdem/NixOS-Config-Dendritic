# Flake parts modules
{
  config,
  lib,
  ...
}: {
  # TODO: Delete after den
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "shell")
  ];
}

# Flake partsq inif modules
{
  config,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "video")
    (config.factory.inclusionModules "mpv")
    (config.factory.inclusionModules "obs")
    (config.factory.inclusionModules "yt-dlp")
  ];
}

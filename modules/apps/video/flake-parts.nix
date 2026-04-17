# Flake partsq inif modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (inputs.self.factory.inclusionModules "video")
    (inputs.self.factory.inclusionModules "droidcam")
    (inputs.self.factory.inclusionModules "mpv")
    (inputs.self.factory.inclusionModules "obs")
    (inputs.self.factory.inclusionModules "yt-dlp")
  ];
}

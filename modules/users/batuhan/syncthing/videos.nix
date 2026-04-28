# Configuring synching video directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncthingXdg {
    userDir = "videos";
    nameUser = "batuhan";
    aliasUser = "wolframite";
    sharedHosts = [
      "su-ana"
    ];
  };
}

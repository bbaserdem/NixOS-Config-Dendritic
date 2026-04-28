# Configuring syncthing music directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncthingXdg {
    userDir = "music";
    nameUser = "batuhan";
    aliasUser = "wolframite";
    sharedHosts = [
      "su-ana"
    ];
  };
}

# Configuring syncthing music directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncMediaDir {
    userDir = "music";
    nameUser = "batuhan";
    aliasUser = "wolframite";
    sharedHosts = [
      "su-ana"
    ];
  };
}

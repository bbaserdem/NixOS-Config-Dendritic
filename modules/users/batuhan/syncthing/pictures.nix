# Configuring syncthing pictures directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncMediaDir {
    userDir = "pictures";
    nameUser = "batuhan";
    aliasUser = "wolframite";
    sharedHosts = [
      "su-ana"
    ];
  };
}

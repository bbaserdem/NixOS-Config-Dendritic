# Configuring syncthing pictures directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncMediaDir {
    userDir = "download";
    userDirPretty = "Downloads";
    userDirDarwin = "Downloads";
    nameUser = "batuhan";
    aliasUser = "wolframite";
    sharedHosts = [
      "su-ana"
    ];
  };
}

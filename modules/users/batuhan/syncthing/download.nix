# Configuring syncthing pictures directory
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncthingXdg {
    userDir = "download";
    nameUser = "batuhan";
    aliasUser = "wolframite";
    sharedHosts = [
      "su-ana"
    ];
  };
}
